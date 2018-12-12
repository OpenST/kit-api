module ManagerManagement

  class Invite < ServicesBase

    # Initialize
    #
    # * Author: Puneet
    # * Date: 06/12/2018
    # * Reviewed By:
    #
    # @param [Integer] manager_id (mandatory) - id of the manager who is sending an invite to below email
    # @param [Integer] client_id (mandatory) - id of the client to which invite is for
    # @param [String] email (mandatory) - the email of the user which is to be invited
    #
    # @return [ManagerManagement::Invite]
    #
    def initialize(params)

      super

      @email = @params[:email]
      @inviter_manager_id = @params[:manager_id]
      @client_id = @params[:client_id]

      @invitee_manager = nil
      @invite_token = nil
      @authentication_salt_hash = nil

    end

    # Perform
    #
    # * Author: Puneet
    # * Date: 06/12/2018
    # * Reviewed By:
    #
    # @return [Result::Base]
    #
    def perform

      handle_errors_and_exceptions do

        validate_and_sanitize

        fetch_and_validate_inviter_manager

        create_manager_for_invitee

        create_invite_token

        create_client_manager

        enqueue_job

        success_with_data({})

      end

    end

    private

    # Validate and sanitize
    #
    # * Author: Puneet
    # * Date: 06/12/2018
    # * Reviewed By:
    #
    # @return [Result::Base]
    #
    def validate_and_sanitize

      validation_errors = []

      @email = @email.to_s.downcase.strip
      validation_errors.push('invalid_email') unless Util::CommonValidator.is_valid_email?(@email)
      validation_errors.push('email_not_allowed_for_dev_program') unless Util::CommonValidator.is_whitelisted_email?(@email)

      fail OstCustomError.new validation_error(
                                  'm_su_1',
                                  'invalid_api_params',
                                  validation_errors,
                                  GlobalConstant::ErrorAction.default
                              ) if validation_errors.present?

      # NOTE: To be on safe side, check for generic errors as well
      validate

    end

    # Validate inviter manager
    #
    # * Author: Puneet
    # * Date: 06/12/2018
    # * Reviewed By:
    #
    # @return [Result::Base]
    #
    def fetch_and_validate_inviter_manager

      client_manager = CacheManagement::ClientManager.new(
          [@inviter_manager_id],
          {client_id: @client_id}).fetch[@inviter_manager_id]

      fail OstCustomError.new error_with_data(
          'um_su_5',
          'unauthorized_access_response',
          GlobalConstant::ErrorAction.default
      ) if client_manager.blank?

      fail OstCustomError.new error_with_data(
                                  'um_su_6',
                                  'unauthorized_access_response',
                                  GlobalConstant::ErrorAction.default
                              ) if client_manager[:privilages].exclude?(GlobalConstant::ClientManager.is_super_admin_privilage)

      success

    end

    # create manager
    #
    # * Author: Puneet
    # * Date: 06/12/2018
    # * Reviewed By:
    #
    # @return [Result::Base]
    #
    def create_manager_for_invitee

      @invitee_manager = Manager.where(email: @email).first

      if @invitee_manager.present?

        if @invitee_manager.status != GlobalConstant::Manager.invited_status

          fail OstCustomError.new validation_error(
                                      'um_su_4',
                                      'invalid_api_params',
                                      ['already_registered_email'],
                                      GlobalConstant::ErrorAction.default
                                  )

        else
          return success
        end

      end

      generate_login_salt

      @invitee_manager = Manager.new(
          email: @email,
          authentication_salt: @authentication_salt_hash[:ciphertext_blob],
          status: GlobalConstant::Manager.invited_status
      )

      @invitee_manager.save!

      success

    end

    # Generate login salt
    #
    # * Author: Puneet
    # * Date: 06/12/2018
    # * Reviewed By:
    #
    # Sets @authentication_salt_hash
    #
    # @return [Result::Base]
    #
    def generate_login_salt
      r = Aws::Kms.new('login', 'user').generate_data_key
      fail OstCustomError.new r unless r.success?

      @authentication_salt_hash = r.data

      success
    end

    # Generate invite token
    #
    # * Author: Puneet
    # * Date: 06/12/2018
    # * Reviewed By:
    #
    # Sets @invite_token
    #
    # @return [Result::Base]
    #
    def create_invite_token

      # local cipher encrypt token
      invite_token_d = LocalCipher.get_sha_hashed_text(
          "#{@client_id}::#{@email}::#{current_timestamp}::invite::#{rand}"
      )

      db_row = ManagerValidationHash.create!(
          manager_id: @invitee_manager.id,
          client_id: @client_id,
          kind: GlobalConstant::ManagerValidationHash.manager_invite_kind,
          validation_hash: invite_token_d,
          status: GlobalConstant::ManagerValidationHash.active_status
      )

      # create a custom key using db id and local cipher encrypt token
      invite_token_str = "#{db_row.id}#{ManagerValidationHash.token_delimitter}#{invite_token_d}"

      # encrypt it again to send it over in email
      encryptor_obj = EmailTokenEncryptor.new(GlobalConstant::SecretEncryptor.email_tokens_key)
      r = encryptor_obj.encrypt(invite_token_str)
      fail OstCustomError.new(r) unless r.success?

      @invite_token = r.data[:ciphertext_blob]

    end

    # Create Client Manager
    #
    # * Author: Puneet
    # * Date: 08/12/2018
    # * Reviewed By:
    #
    # @return [Result::Base]
    #
    def create_client_manager

      cm = ClientManager.new(
         client_id: @client_id,
         manager_id: @invitee_manager.id,
      )

      cm.send("set_#{GlobalConstant::ClientManager.is_invited_privilage}")
      cm.save!

      success

    end

    # Enqueue Job
    #
    # * Author: Puneet
    # * Date: 08/12/2018
    # * Reviewed By:
    #
    # @return [Result::Base]
    #
    def enqueue_job
      #TODO: Enqueue job to send email
      puts "invite_token: #{@invite_token}"
    end

  end

end
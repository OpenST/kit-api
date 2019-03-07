module ManagerManagement

  module Team

    class InviteAdmin < ServicesBase

      # Initialize
      #
      # * Author: Puneet
      # * Date: 06/12/2018
      # * Reviewed By: Sunil
      #
      # @params [Integer] manager_id (mandatory) - id of the manager who is sending an invite to below email
      # @params [Integer] client_id (mandatory) - id of the client to which invite is for
      # @params [String] email (mandatory) - the email of the user which is to be invited
      # @params [Integer] is_super_admin (mandatory) - the privilege of the admin once the invite is accepted. 1 => super_admin, 0 => admin
      # @params [Hash] client_manager (mandatory) - logged in client manager object
      #
      # @return [ManagerManagement::Team::InviteAdmin]
      #
      def initialize(params)
        super

        @email = @params[:email]
        @inviter_manager_id = @params[:manager_id]
        @client_id = @params[:client_id]
        @is_super_admin = @params[:is_super_admin].to_s
        @inviter_client_manager = @params[:client_manager]

        @invitee_manager = nil
        @invitee_client_manager = nil
        @invite_token = nil
        @authentication_salt_hash = nil
      end

      # Perform
      #
      # * Author: Puneet
      # * Date: 06/12/2018
      # * Reviewed By: Sunil
      #
      # @return [Result::Base]
      #
      def perform

        handle_errors_and_exceptions do

          r = validate_and_sanitize
          return r unless r.success?

          r = create_manager_for_invitee
          return r unless r.success?

          r = create_invite_token
          return r unless r.success?

          r = create_client_manager
          return r unless r.success?

          r = enqueue_job
          return r unless r.success?

          success_with_data({
                                result_type: result_type,
                                result_type => [
                                    @invitee_client_manager.formated_cache_data
                                ],
                                managers: {
                                    @invitee_manager.id => @invitee_manager.formated_cache_data
                                }
                            })

        end

      end

      private

      # Validate and sanitize
      #
      # * Author: Puneet
      # * Date: 06/12/2018
      # * Reviewed By: Sunil
      #
      # @return [Result::Base]
      #
      def validate_and_sanitize

        # NOTE: To be on safe side, check for generic errors as well
        r = validate
        return r unless r.success?

        validation_errors = []

        @email = @email.to_s.downcase.strip
        validation_errors.push('invalid_email') unless Util::CommonValidator.is_valid_email?(@email)
        validation_errors.push('invalid_is_super_admin') unless Util::CommonValidator.is_boolean_string?(@is_super_admin)

        return validation_error(
          's_mm_sa_ia_1',
          'invalid_api_params',
          validation_errors,
          GlobalConstant::ErrorAction.default
        ) if validation_errors.present?

        success

      end

      # validate
      #
      # * Author: Kedar
      # * Date: 22/02/2019
      # * Reviewed By: Puneet
      #
      # @return [Result::Base]
      #
      def validate
        r = super
        return r unless r.success?

        r = ManagerManagement::Team::CheckSuperAdminRole.new(
          {client_manager: @inviter_client_manager}).perform

        unless r.success?
          return error_with_data(
            's_mm_sa_ia_2',
            'unauthorized_to_perform_action',
            GlobalConstant::ErrorAction.default
          )
        end

        success
      end

      # create manager
      #
      # * Author: Puneet
      # * Date: 06/12/2018
      # * Reviewed By: Sunil
      #
      # @return [Result::Base]
      #
      def create_manager_for_invitee

        @invitee_manager = Manager.where(email: @email).first

        # If invitee_manager is present, that is an error.
        if @invitee_manager.present?

          # If invitee_manager is associated with the current client, two conditions are possible.
          # Either the invitee_manager was previously associated with the client, or is currently associated with the client.
          if @invitee_manager.current_client_id == @client_id

            # Fetch client_manager to check if the invitee_manager was previously associated with the client.
            @invitee_client_manager = ClientManager.where(client_id: @client_id, manager_id: @invitee_manager.id).first

            # If client_manager is present, check for privileges.
            if @invitee_client_manager.present? && @invitee_client_manager.privileges.present?

              privileges = ClientManager.get_bits_set_for_privileges(@invitee_client_manager.privileges)

              # If privileges includes has_been_deleted_privilege, display error message that the admin WAS
              # previously associated with the client.
              if privileges.include?(GlobalConstant::ClientManager.has_been_deleted_privilege)

                return validation_error(
                  's_mm_sa_ia_3',
                  'invalid_api_params',
                  ['was_current_client_associated_email'],
                  GlobalConstant::ErrorAction.default
                )
                # If privileges excludes has_been_deleted_privilege, display error message that the admin IS
                # currently associated with the client. We don't handle that error condition here because it is handled
                # in the previous if block.

              end

            end

            # The invitee_manager IS currently associated with the client.
            return validation_error(
              's_mm_sa_ia_4',
              'invalid_api_params',
              ['is_current_client_associated_email'],
              GlobalConstant::ErrorAction.default
            )
          else

            # The invitee_manager is associated to some other client.
            return validation_error(
              's_mm_sa_ia_5',
              'invalid_api_params',
              ['already_client_associated_email'],
              GlobalConstant::ErrorAction.default
            )

          end

        end

        r = generate_login_salt
        return r unless r.success?

        @invitee_manager = Manager.new(
          email: @email,
          authentication_salt: @authentication_salt_hash[:ciphertext_blob],
          current_client_id: @client_id,
          status: GlobalConstant::Manager.invited_status
        )

        @invitee_manager.save!

        success

      end

      # Generate login salt
      #
      # * Author: Puneet
      # * Date: 06/12/2018
      # * Reviewed By: Sunil
      #
      # Sets @authentication_salt_hash
      #
      # @return [Result::Base]
      #
      def generate_login_salt
        r = Aws::Kms.new(GlobalConstant::Kms.login_purpose, GlobalConstant::Kms.user_role).generate_data_key
        return r unless r.success?

        @authentication_salt_hash = r.data

        success
      end

      # Generate invite token
      #
      # * Author: Puneet
      # * Date: 06/12/2018
      # * Reviewed By: Sunil
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

        Util::CommonValidator.is_true_boolean_string?(@is_super_admin) ?
          invitee_admin_privilege = GlobalConstant::ClientManager.is_super_admin_privilege
          : invitee_admin_privilege = GlobalConstant::ClientManager.is_admin_privilege

        db_row = ManagerValidationHash.create!(
          manager_id: @invitee_manager.id,
          client_id: @client_id,
          kind: GlobalConstant::ManagerValidationHash.manager_invite_kind,
          validation_hash: invite_token_d,
          status: GlobalConstant::ManagerValidationHash.active_status,
          extra_data: {
            inviter_manager_id: @inviter_manager_id,
            is_super_admin: invitee_admin_privilege
          }
        )

        # create a custom key using db id and local cipher encrypt token
        invite_token_str = "#{db_row.id}#{ManagerValidationHash.token_delimitter}#{invite_token_d}"

        # encrypt it again to send it over in email
        encryptor_obj = EmailTokenEncryptor.new(GlobalConstant::SecretEncryptor.email_tokens_key)
        r = encryptor_obj.encrypt(invite_token_str, GlobalConstant::ManagerValidationHash::manager_invite_kind)
        return r unless r.success?

        @invite_token = r.data[:ciphertext_blob]

        success

      end

      # Create Client Manager
      #
      # * Author: Puneet
      # * Date: 08/12/2018
      # * Reviewed By: Sunil
      #
      # @return [Result::Base]
      #
      def create_client_manager

        if @invitee_client_manager.present? && @invitee_client_manager.privileges.present?
          privileges = ClientManager.get_bits_set_for_privileges(@invitee_client_manager.privileges) - [GlobalConstant::ClientManager.is_admin_invited_privilege] - [GlobalConstant::ClientManager.is_super_admin_invited_privilege]
          # if any other privilege was set other than invite, either invite was already accepted or rejected.
          return validation_error(
            'mm_su_ia_5',
            'invalid_api_params',
            ['already_registered_email'],
            GlobalConstant::ErrorAction.default
          ) if privileges.any?
        end

        @invitee_client_manager ||= ClientManager.new(client_id: @client_id, manager_id: @invitee_manager.id)

        Util::CommonValidator.is_true_boolean_string?(@is_super_admin) ?
          @invitee_client_manager.send("set_#{GlobalConstant::ClientManager.is_super_admin_invited_privilege}")
          : @invitee_client_manager.send("set_#{GlobalConstant::ClientManager.is_admin_invited_privilege}")

        @invitee_client_manager.save! if @invitee_client_manager.changed?

        success

      end

      # Enqueue Job
      #
      # * Author: Puneet
      # * Date: 08/12/2018
      # * Reviewed By: Sunil
      #
      # @return [Result::Base]
      #
      def enqueue_job
        BackgroundJob.enqueue(
            InviteJob,
            {
                manager_id: @invitee_manager.id,
                invite_token: @invite_token
            }
        )
        success
      end

      # Result type
      #
      # * Author: Puneet
      # * Date: 08/12/2018
      # * Reviewed By: Sunil
      #
      # @return [Symbol]
      #
      def result_type
        :client_managers
      end

    end

  end

end
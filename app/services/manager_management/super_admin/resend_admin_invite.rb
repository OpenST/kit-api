module ManagerManagement

  module SuperAdmin

    class ResendAdminInvite < ServicesBase

      # Initialize
      #
      # * Author: Puneet
      # * Date: 06/12/2018
      # * Reviewed By:
      #
      # @param [Integer] manager_id (mandatory) - id of the manager who is sending an invite to below email
      # @param [Integer] client_id (mandatory) - id of the client to which invite is for
      # @param [String] to_update_client_manager_id (mandatory) - id of the client_manager which is to be re-invited.
      #
      # @return [ManagerManagement::SuperAdmin::InviteAdmin]
      #
      def initialize(params)

        super

        @to_update_client_manager_id = @params[:to_update_client_manager_id]
        @inviter_manager_id = @params[:manager_id]
        @client_id = @params[:client_id]

        @invitee_manager = nil
        @invite_token = nil

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

          validate

          fetch_client_manager

          validate_invitee_manager_exists

          create_invite_token

          enqueue_job

          success

        end

      end

      private

      # Fetch client manager
      #
      # * Author: Puneet
      # * Date: 06/12/2018
      # * Reviewed By:
      #
      # @return [Result::Base]
      #
      def fetch_client_manager

        @to_update_client_manager = ClientManager.where(id: @to_update_client_manager_id).first

        fail OstCustomError.new validation_error(
                                  'mm_su_rai_1',
                                  'manager_not_invited',
                                  [],
                                  GlobalConstant::ErrorAction.default
                                ) if @to_update_client_manager.blank?

        fail OstCustomError.new validation_error(
                                  'mm_su_rai_2',
                                  'unauthorized_access_response',
                                  [],
                                  GlobalConstant::ErrorAction.default
                                ) if @to_update_client_manager.manager_id == @manager_id

        success

      end

      # Validate and sanitize
      #
      # * Author: Shlok
      # * Date: 10/01/2019
      # * Reviewed By:
      #
      # @return [Result::Base]
      #
      def validate_invitee_manager_exists

        @invitee_manager = Manager.where(id: @to_update_client_manager.manager_id).first

        # If invitee_manager is present, that is an error.
        if @invitee_manager.present?

          # If invitee_manager is associated with the current client, two conditions are possible.
          # Either the invitee_manager was previously associated with the client, or is currently associated with the client.
          if @invitee_manager.current_client_id == @client_id

            privileges = ClientManager.get_bits_set_for_privileges(@to_update_client_manager.privileges)

            # If privileges includes has_been_deleted_privilege, display error message that the admin WAS
            # previously associated with the client.
            fail OstCustomError.new validation_error(
                                      'mm_su_rai_3',
                                      'invalid_api_params',
                                      ['was_current_client_associated_deleted_manager'],
                                      GlobalConstant::ErrorAction.default
                                    ) if privileges.include?(GlobalConstant::ClientManager.has_been_deleted_privilege)


            # Check whether the admin is active or not.
            is_client_manager_active = privileges.include?(GlobalConstant::ClientManager.is_super_admin_privilege) ||
              privileges.include?(GlobalConstant::ClientManager.is_admin_privilege)

            # The invitee_manager IS currently associated with the client and active.
            fail OstCustomError.new validation_error(
                                      'mm_su_rai_4',
                                      'invalid_api_params',
                                      ['is_active_current_client_associated_manager'],
                                      GlobalConstant::ErrorAction.default
                                    ) if is_client_manager_active

            # Decide the privilege for the new invite.
            if privileges.include?(GlobalConstant::ClientManager.is_admin_invited_privilege)
              @admin_invite_privilege = GlobalConstant::ClientManager.is_admin_privilege
            elsif privileges.include?(GlobalConstant::ClientManager.is_super_admin_invited_privilege)
              @admin_invite_privilege = GlobalConstant::ClientManager.is_super_admin_privilege
            end

          end

        else

          # The clientId is invalid.
          fail OstCustomError.new validation_error(
                                    'mm_su_rai_5',
                                    'invalid_api_params',
                                    ['already_client_associated_manager'],
                                    GlobalConstant::ErrorAction.default
                                  )

        end

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
          status: GlobalConstant::ManagerValidationHash.active_status,
          extra_data: {
            inviter_manager_id: @inviter_manager_id,
            is_super_admin: @admin_invite_privilege
          }
        )

        # create a custom key using db id and local cipher encrypt token
        invite_token_str = "#{db_row.id}#{ManagerValidationHash.token_delimitter}#{invite_token_d}"

        # encrypt it again to send it over in email
        encryptor_obj = EmailTokenEncryptor.new(GlobalConstant::SecretEncryptor.email_tokens_key)
        r = encryptor_obj.encrypt(invite_token_str, GlobalConstant::ManagerValidationHash::manager_invite_kind)
        fail OstCustomError.new(r) unless r.success?

        @invite_token = r.data[:ciphertext_blob]

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
        BackgroundJob.enqueue(
            InviteJob,
            {
                manager_id: @invitee_manager.id,
                invite_token: @invite_token
            }
        )
      end

    end

  end

end
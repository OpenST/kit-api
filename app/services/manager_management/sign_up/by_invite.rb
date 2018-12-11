module ManagerManagement

  module SignUp

    class ByInvite < ManagerManagement::SignUp::Base

      # Initialize
      #
      # * Author: Puneet
      # * Date: 06/12/2018
      # * Reviewed By:
      #
      # @param [String] i_t (mandatory) - token if this user is signing up from via a manager invite link
      # @param [String] password (mandatory) - user password
      # @param [String] browser_user_agent (mandatory) - browser user agent
      #
      # @return [ManagerManagement::SignUp::ByInvite]
      #
      def initialize(params)

        super

        @invite_token = @params[:i_t]

        @decrypted_invite_token = nil
        @manager_validation_hash = nil

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

          # 1. decode i_t to determine email and client to which invite is for
          # 2. find manager & client record

          decrypt_invite_token

          validate_invite_token

          fetch_and_validate_invited_manager

          fetch_and_validate_client

          decrypt_login_salt

          update_manager

          create_client_manager

          update_invite_token

          set_cookie_value

          enqueue_job

          success_with_data(
          {cookie_value: @cookie_value},
            fetch_go_to
          )

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

        validation_errors.push('password_incorrect') unless Util::CommonValidator.is_valid_password?(@password)

        if @invite_token.blank?
          validation_errors.push('missing_i_t')
        else
          @invite_token = @invite_token.to_s.strip
        end

        fail OstCustomError.new validation_error(
                                    'm_su_1',
                                    'invalid_api_params',
                                    validation_errors,
                                    GlobalConstant::ErrorAction.default
                                ) if validation_errors.present?

        # NOTE: To be on safe side, check for generic errors as well
        validate

      end

      # Decrypt login salt
      #
      # * Author: Puneet
      # * Date: 06/12/2018
      # * Reviewed By:
      #
      # Sets @login_salt_d
      #
      # @return [Result::Base]
      #
      def decrypt_login_salt

        r = Aws::Kms.new('login','user').decrypt(@manager.authentication_salt)
        fail r unless r.success?

        @login_salt_d = r.data[:plaintext]

        success

      end

      # modify invited manager object
      #
      # * Author: Puneet
      # * Date: 06/12/2018
      # * Reviewed By:
      #
      # @return [Result::Base]
      #
      def update_manager

        @manager.password = Manager.get_encrypted_password(@password, @login_salt_d)
        @manager.current_client_id = @client_id
        @manager.status = GlobalConstant::Manager.active_status
        @manager.last_session_updated_at = current_timestamp
        @manager.save

      end

      # set privilages
      #
      # * Author: Puneet
      # * Date: 06/12/2018
      # * Reviewed By:
      #
      # @return [Result::Base]
      #
      def add_privilages_to_client_manager
        @client_manager.send("set_#{GlobalConstant::ClientManager.is_mainnet_admin_privilage}")
        @client_manager.send("set_#{GlobalConstant::ClientManager.is_sandbox_admin_privilage}")
        success
      end

      # Update Invite Token
      #
      # * Author: Puneet
      # * Date: 06/12/2018
      # * Reviewed By:
      #
      # @return [Result::Base]
      #
      def update_invite_token

        # Mark this invite token as used
        @manager_validation_hash.status = GlobalConstant::ManagerValidationHash.used_status
        @manager_validation_hash.save!

        # Mark any other active invite token (s) for this manager as inactive
        ManagerValidationHash.where(
            manager_id: @manager_id,
            kind: GlobalConstant::ManagerValidationHash.manager_invite_kind,
            status: GlobalConstant::ManagerValidationHash.active_status
        ).update_all(
            status: GlobalConstant::ManagerValidationHash.inactive_status
        )

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

        BackgroundJob.enqueue(
            SignUpViaInviteJob,
            {
                manager_id: @manager_id
            }
        )

      end

    end

  end

end
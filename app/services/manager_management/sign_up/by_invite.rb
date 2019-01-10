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
      # @param [String] confirm_password (mandatory) - user password
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

          fetch_and_validate_inviter_manager

          decrypt_login_salt

          update_manager

          update_client_manager

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
      # * Author: Shlok
      # * Date: 12/12/2018
      # * Reviewed By:
      #
      # @return [Result::Base]
      #
      def validate_and_sanitize

        validation_errors = []

        validation_errors.push('password_incorrect') unless Util::CommonValidator.is_valid_password?(@password)
        validation_errors.push('confirm_password_invalid') if @confirm_password != @password

        if @invite_token.blank?

          validation_errors.push('missing_i_t')

        else

          @invite_token = @invite_token.to_s.strip

          unless Util::CommonValidator.is_valid_token?(@invite_token)
            validation_errors.push('invalid_i_t')
          end

        end

        fail OstCustomError.new validation_error(
                                    'mm_su_bi_2',
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

        r = Aws::Kms.new('login','user').decrypt(@manager_obj.authentication_salt)
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

        @manager_obj.password = Manager.get_encrypted_password(@password, @login_salt_d)
        @manager_obj.current_client_id = @client_id
        @manager_obj.send("set_#{GlobalConstant::Manager.has_verified_email_property}")
        @manager_obj.status = GlobalConstant::Manager.active_status
        @manager_obj.last_session_updated_at = current_timestamp
        @manager_obj.save

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

      # Create client manager
      #
      # * Author: Puneet
      # * Date: 06/12/2018
      # * Reviewed By:
      #
      # Sets @client_manager_obj
      #
      def update_client_manager

        @client_manager_obj = ClientManager.where(
            client_id: @client_id,
            manager_id: @manager_obj.id
        ).first

        # Decide invite privilege depending on the is_super_admin set in the manager validation hash.
        if @is_super_admin == GlobalConstant::ClientManager.is_super_admin_privilege
          @client_manager_obj.send("unset_#{GlobalConstant::ClientManager.is_super_admin_invited_privilege}")
          @client_manager_obj.send("set_#{GlobalConstant::ClientManager.is_super_admin_privilege}")
        else
          @client_manager_obj.send("unset_#{GlobalConstant::ClientManager.is_admin_invited_privilege}")
          @client_manager_obj.send("set_#{GlobalConstant::ClientManager.is_admin_privilege}")
        end

        @client_manager_obj.save!

      end

      # Get goto for next page
      #
      # * Author: Shlok
      # * Date: 07/01/2019
      # * Reviewed By:
      #
      # @return [Hash]
      #
      def fetch_go_to
        GlobalConstant::GoTo.setup_mfa
      end

    end

  end

end
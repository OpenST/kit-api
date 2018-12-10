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

          fetch_and_validate_manager

          fetch_and_validate_client

          decrypt_login_salt

          update_manager

          create_client_manager

          update_invite_token

          set_cookie_value

          clear_cache

          enqueue_job

          success_with_data(
              cookie_value: @cookie_value
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

      # Decode Invite Token
      #
      # * Author: Puneet
      # * Date: 06/12/2018
      # * Reviewed By:
      #
      # @return [Result::Base]
      #
      # Sets @decrypted_invite_token
      #
      def decrypt_invite_token
        decryptor_obj = EmailTokenEncryptor.new(GlobalConstant::SecretEncryptor.email_tokens_key)
        r = decryptor_obj.decrypt(@invite_token)
        return r unless r.success?
        @decrypted_invite_token = r.data[:plaintext]
        success
      end

      # Validate Invite Token
      #
      # * Author: Puneet
      # * Date: 06/12/2018
      # * Reviewed By:
      #
      # @return [Result::Base]
      #
      # Sets @manager_validation_hash
      #
      def validate_invite_token

        splited_reset_token = @decrypted_invite_token.split(ManagerValidationHash.token_delimitter)
        invalid_url_error('um_rp_1') if splited_reset_token.length != 2

        validation_hash = splited_reset_token[1]
        manager_validation_hash_id = splited_reset_token[0]

        invalid_url_error('um_rp_3') unless Util::CommonValidator.is_numeric?(manager_validation_hash_id)

        invalid_url_error('um_rp_4') unless Util::CommonValidator.is_alphanumeric?(validation_hash)

        @manager_validation_hash = ManagerValidationHash.where(id: manager_validation_hash_id.to_i).first

        invalid_url_error('um_rp_4') if @manager_validation_hash.blank?

        invalid_url_error('um_rp_5') if @manager_validation_hash.validation_hash != validation_hash

        invalid_url_error('um_rp_6') if @manager_validation_hash.status != GlobalConstant::ManagerValidationHash.active_status

        invalid_url_error('um_rp_7') if @manager_validation_hash.is_expired?

        invalid_url_error('um_rp_8') if @manager_validation_hash.kind != GlobalConstant::ManagerValidationHash.manager_invite_kind

        @client_id = @manager_validation_hash.client_id
        @manager_id = @manager_validation_hash.manager_id

        success

      end

      # Invalid Request Response
      #
      # * Author: Pankaj
      # * Date: 11/01/2018
      # * Reviewed By:
      #
      # @return [Result::Base]
      #
      def invalid_url_error(code)
        fail OstCustomError.new validation_error(
                 code,
                 'invalid_api_params',
                 ['invalid_r_t'],
                 GlobalConstant::ErrorAction.default
             )
      end

      # Find & validate manager
      #
      # * Author: Puneet
      # * Date: 06/12/2018
      # * Reviewed By:
      #
      # @return [Result::Base]
      #
      def fetch_and_validate_manager

        @manager = Manager.where(id: @manager_id).first

        invalid_url_error('um_rp_9') if @manager.blank?

        invalid_url_error('um_rp_10') if @manager.status != GlobalConstant::Manager.invited_status

        success

      end

      # Find & validate client
      #
      # * Author: Puneet
      # * Date: 06/12/2018
      # * Reviewed By:
      #
      # @return [Result::Base]
      #
      def fetch_and_validate_client

        @client = CacheManagement::Client.new([@client_id]).fetch[@client_id]

        invalid_url_error('um_rp_11') if @client.blank?

        if Util::CommonValidator.is_mainnet_env?
          invalid_url_error('um_rp_12') if @client[:mainnet_statuses].include?(GlobalConstant::Client.mainnet_active_status)
        else
          invalid_url_error('um_rp_13') if @client[:sandbox_statuses].include?(GlobalConstant::Client.sandbox_inactive_status)
        end

        success

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
        if Util::CommonValidator.is_mainnet_env?
          @client_manager.send("set_#{GlobalConstant::ClientManager.is_mainnet_admin_privilage}")
        else
          @client_manager.send("set_#{GlobalConstant::ClientManager.is_sandbox_admin_privilage}")
        end
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
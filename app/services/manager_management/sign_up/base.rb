module ManagerManagement

  module SignUp

    class Base < ServicesBase

      # Initialize
      #
      # * Author: Puneet
      # * Date: 06/12/2018
      # * Reviewed By:
      #
      # @param [String] password (mandatory) - user password
      # @param [String] confirm_password (mandatory) - user password
      # @param [String] browser_user_agent (mandatory) - browser user agent
      #
      # @return [ManagerManagement::SignUp::ByInvite]
      #
      def initialize(params)

        super

        @password = @params[:password]
        @confirm_password = @params[:confirm_password]
        @browser_user_agent = @params[:browser_user_agent]

        @client_id = nil
        @manager_id = nil
        @manager_obj = nil
        @client = nil
        @client_manager_obj = nil
        @cookie_value = nil
        @invite_token = nil
        @decrypted_invite_token = nil

      end

      private

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
        invalid_url_error('mm_su_b_9') unless r.success?
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
        invalid_url_error('mm_su_b_1') if splited_reset_token.length != 2

        validation_hash = splited_reset_token[1]
        manager_validation_hash_id = splited_reset_token[0]

        invalid_url_error('mm_su_b_3') unless Util::CommonValidator.is_numeric?(manager_validation_hash_id)

        invalid_url_error('mm_su_b_4') unless Util::CommonValidator.is_alphanumeric?(validation_hash)

        @manager_validation_hash = ManagerValidationHash.where(id: manager_validation_hash_id.to_i).first

        invalid_url_error('mm_su_b_4') if @manager_validation_hash.blank?

        invalid_url_error('mm_su_b_5') if @manager_validation_hash.validation_hash != validation_hash

        invalid_url_error('mm_su_b_6') if @manager_validation_hash.status != GlobalConstant::ManagerValidationHash.active_status

        invalid_url_error('mm_su_b_7') if @manager_validation_hash.is_expired?

        invalid_url_error('mm_su_b_8') if @manager_validation_hash.kind != GlobalConstant::ManagerValidationHash.manager_invite_kind

        @client_id = @manager_validation_hash.client_id
        @manager_id = @manager_validation_hash.manager_id
        @inviter_manager_id = @manager_validation_hash.extra_data[:inviter_manager_id].to_i
        @is_super_admin = @manager_validation_hash.extra_data[:is_super_admin]

        success

      end

      # Invalid Request Response
      #
      # * Author: Puneet
      # * Date: 11/01/2018
      # * Reviewed By:
      #
      # @return [Result::Base]
      #
      def invalid_url_error(code)
        fail OstCustomError.new validation_error(
                                    code,
                                    'invalid_api_params',
                                    ['invalid_i_t'],
                                    GlobalConstant::ErrorAction.default
                                )
      end

      # Find & validate invited manager
      #
      # * Author: Puneet
      # * Date: 06/12/2018
      # * Reviewed By:
      #
      # @return [Result::Base]
      #
      def fetch_and_validate_invited_manager

        @manager_obj = Manager.where(id: @manager_id).first

        invalid_url_error('mm_su_b_9') if @manager_obj.blank?

        invalid_url_error('mm_su_b_10') if @manager_obj.status != GlobalConstant::Manager.invited_status

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
        begin
          @client = Util::EntityHelper.fetch_and_validate_client(@client_id, 'um_rp')
        rescue OstCustomError => ose
          invalid_url_error(ose.internal_id)
        end
        success
      end

      # Find & validate inviter manager
      #
      # * Author: Puneet
      # * Date: 06/12/2018
      # * Reviewed By:
      #
      # @return [Result::Base]
      #
      def fetch_and_validate_inviter_manager

        begin
          @inviter_manager = Util::EntityHelper.fetch_and_validate_manager(@inviter_manager_id, 'um_rp')
        rescue OstCustomError => ose
          invalid_url_error(ose.internal_id)
        end

        client_manager = CacheManagement::ClientManager.new([@inviter_manager_id], {client_id: @client_id}).fetch[@inviter_manager_id]
        invalid_url_error('mm_su_b_15') if client_manager[:privileges].exclude?(GlobalConstant::ClientManager.is_super_admin_privilege)

        success

      end

      # Set cookie value
      #
      # * Author: Puneet
      # * Date: 06/12/2018
      # * Reviewed By:
      #
      # Sets @cookie_value
      #
      def set_cookie_value
        @cookie_value = Manager.get_cookie_value(
            manager_id: @manager_obj.id,
            current_client_id: @manager_obj.current_client_id,
            token_s: @manager_obj.password,
            browser_user_agent: @browser_user_agent,
            last_session_updated_at: @manager_obj.last_session_updated_at,
            auth_level: GlobalConstant::Cookie.password_auth_prefix
        )
        success
      end

      # Get goto for next page
      #
      # * Author: Puneet
      # * Date: 08/12/2018
      # * Reviewed By:
      #
      # @return [Hash]
      #
      def fetch_go_to
        GlobalConstant::GoTo.verify_email
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
            SignUpJob,
            {
                manager_id: @manager_obj.id
            }
        )

      end

    end

  end

end
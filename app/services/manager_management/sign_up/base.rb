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
      # @param [String] browser_user_agent (mandatory) - browser user agent
      #
      # @return [ManagerManagement::SignUp::ByInvite]
      #
      def initialize(params)

        super

        @password = @params[:password]
        @browser_user_agent = @params[:browser_user_agent]

        @client_id = nil
        @manager_id = nil
        @manager = nil
        @client = nil
        @client_manager = nil
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
      def fetch_and_validate_invited_manager

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

      # Create client manager
      #
      # * Author: Puneet
      # * Date: 06/12/2018
      # * Reviewed By:
      #
      # Sets @client_manager
      #
      def create_client_manager

        @client_manager = ClientManager.new(
            client_id: @client_id,
            manager_id: @manager.id
        )

        add_privilages_to_client_manager

        @client_manager.save!

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
            manager_id: @manager.id,
            current_client_id: @manager.current_client_id,
            token_s: @manager.password,
            browser_user_agent: @browser_user_agent,
            last_session_updated_at: @manager.last_session_updated_at,
            auth_level: GlobalConstant::Cookie.password_auth_prefix
        )
        success
      end

    end

  end

end
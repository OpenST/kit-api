module ManagerManagement

  module Login

    class PasswordAuth < ServicesBase
      
      # Initialize
      #
      # * Author: Alpesh
      # * Date: 15/01/2018
      # * Reviewed By:
      #
      # @param [String] email (mandatory) - the email of the user which is to be signed up
      # @param [String] password (mandatory) - user password
      # @params [String] browser_user_agent (mandatory) - browser user agent
      #
      # @return [ManagerManagement::Login::PasswordAuth]
      #
      def initialize(params)
        super

        @email = @params[:email]
        @password = @params[:password]
        @browser_user_agent = @params[:browser_user_agent]

        @manager = nil
        @authentication_salt_d = nil
        
      end

      # Perform
      #
      # * Author: Alpesh
      # * Date: 15/01/2018
      # * Reviewed By:
      #
      # @return [Result::Base]
      #
      def perform

        handle_errors_and_exceptions do

          validate

          fetch_manager

          decrypt_login_salt

          validate_password

          update_manager

          set_cookie_value  
          
        end

      end

      private

      # Fetch user
      #
      # * Author: Alpesh
      # * Date: 15/01/2018
      # * Reviewed By:
      #
      # Sets @manager
      #
      # @return [Result::Base]
      #
      def fetch_manager

        fail OstCustomError.new validation_error(
            'um_l_fu_4',
            'invalid_api_params',
            ['email_not_allowed_for_dev_program'],
            GlobalConstant::ErrorAction.default
        ) unless Util::CommonValidator.is_whitelisted_email?(@email)

        @manager = Manager.where(email: @email).first

        fail OstCustomError.new validation_error(
            'um_l_fu_1',
            'invalid_api_params',
            ['email_not_registered'],
            GlobalConstant::ErrorAction.default
        ) if !@manager.present? || !@manager.password.present? || !@manager.authentication_salt.present?

        fail OstCustomError.new validation_error(
            'um_l_fu_2',
            'invalid_api_params',
            ['email_auto_blocked'],
            GlobalConstant::ErrorAction.default
        ) if @manager.status == GlobalConstant::Manager.auto_blocked_status

        fail OstCustomError.new validation_error(
            'um_l_fu_2',
            'invalid_api_params',
            ['email_inactive'],
            GlobalConstant::ErrorAction.default
        ) if (@manager.status != GlobalConstant::Manager.active_status)

        success

      end

      # Decrypt login salt
      #
      # * Author: Alpesh
      # * Date: 15/01/2018
      # * Reviewed By:
      #
      # Sets @authentication_salt_d
      #
      # @return [Result::Base]
      #
      def decrypt_login_salt
        r = Aws::Kms.new('login','user').decrypt(@manager.authentication_salt)
        return r unless r.success?

        @authentication_salt_d = r.data[:plaintext]

        success
      end

      # Validate password
      #
      # * Author: Alpesh
      # * Date: 15/01/2018
      # * Reviewed By:
      #
      # @return [Result::Base]
      #
      def validate_password

        evaluated_password_e = Manager.get_encrypted_password(@password, @authentication_salt_d)

        unless evaluated_password_e == @manager.password
          manager = Manager.where(id: @manager.id).first # we might have stale data as KMS lookup might take time or ?
          manager.failed_login_attempt_count ||= 0
          manager.failed_login_attempt_count = manager.failed_login_attempt_count + 1
          manager.status = GlobalConstant::Manager.auto_blocked_status if manager.failed_login_attempt_count >= 5
          manager.save
          fail OstCustomError.new validation_error(
              'um_l_fu_2',
              'invalid_api_params',
              ['password_incorrect'],
              GlobalConstant::ErrorAction.default
          )
        end

        success

      end

      # Update last_session_updated_at
      #
      # * Author: Alpesh
      # * Date: 15/01/2018
      # * Reviewed By:
      #
      # @return [Result::Base]
      #
      def update_manager

        @manager.last_session_updated_at = current_timestamp
        @manager.save!

        success

      end

      # Set cookie value
      #
      # * Author: Alpesh
      # * Date: 15/01/2018
      # * Reviewed By:
      #
      # @return [Result::Base]
      #
      def set_cookie_value

        cookie_value = Manager.get_cookie_value(
            manager_id: @manager.id,
            current_client_id: @manager.current_client_id,
            password: @manager.password,
            browser_user_agent: @browser_user_agent,
            last_session_updated_at: @manager.last_session_updated_at,
            auth_level: GlobalConstant::Cookie.password_auth_prefix
        )

        success_with_data(cookie_value: cookie_value)

      end
      
    end

  end

end
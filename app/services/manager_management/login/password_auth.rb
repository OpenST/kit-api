module ManagerManagement

  module Login

    class PasswordAuth < ServicesBase
      
      # Initialize
      #
      # * Author: Puneet
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

        @client = nil
        @client_manager = nil
        @manager_obj = nil
        @authentication_salt_d = nil
        
      end

      # Perform
      #
      # * Author: Puneet
      # * Date: 15/01/2018
      # * Reviewed By:
      #
      # @return [Result::Base]
      #
      def perform

        handle_errors_and_exceptions do

          validate

          fetch_manager

          fetch_client

          fetch_client_manager

          decrypt_login_salt

          validate_password

          update_manager

          set_cookie_value  
          
        end

      end

      private

      # Fetch user
      #
      # * Author: Puneet
      # * Date: 15/01/2018
      # * Reviewed By:
      #
      # Sets @manager_obj
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

        @manager_obj = Manager.where(email: @email).first

        fail OstCustomError.new validation_error(
            'um_l_fu_1',
            'invalid_api_params',
            ['email_not_registered'],
            GlobalConstant::ErrorAction.default
        ) if !@manager_obj.present? || !@manager_obj.password.present? || !@manager_obj.authentication_salt.present?

        fail OstCustomError.new validation_error(
            'um_l_fu_2',
            'invalid_api_params',
            ['email_auto_blocked'],
            GlobalConstant::ErrorAction.default
        ) if @manager_obj.status == GlobalConstant::Manager.auto_blocked_status

        fail OstCustomError.new validation_error(
            'um_l_fu_2',
            'invalid_api_params',
            ['email_inactive'],
            GlobalConstant::ErrorAction.default
        ) if (@manager_obj.status != GlobalConstant::Manager.active_status)

        success

      end

      # Fetch client
      #
      # * Author: Puneet
      # * Date: 15/01/2018
      # * Reviewed By:
      #
      # Sets @client
      #
      # @return [Result::Base]
      #
      def fetch_client
        @client = Util::EntityHelper.fetch_and_validate_client(@manager_obj.current_client_id, 'um_l_fu')
      end

      # Fetch client manager
      #
      # * Author: Puneet
      # * Date: 15/01/2018
      # * Reviewed By:
      #
      # Sets @client_manager
      #
      # @return [Result::Base]
      #
      def fetch_client_manager

        @client_manager = CacheManagement::ClientManager.new([@manager_id],
       {client_id: @manager[:current_client_id]}).fetch[@manager_id]

        client_manager_not_associated_response('mm_l_pa_3') if @client_manager.blank?

        privilages = @client_manager[:privilages]

        is_client_manager_active = privilages.include?(GlobalConstant::ClientManager.is_super_admin_privilage) ||
            privilages.include?(GlobalConstant::ClientManager.is_admin_privilage)

        client_manager_not_associated_response('mm_l_pa_4') unless is_client_manager_active

      end

      # Decrypt login salt
      #
      # * Author: Puneet
      # * Date: 15/01/2018
      # * Reviewed By:
      #
      # Sets @authentication_salt_d
      #
      # @return [Result::Base]
      #
      def decrypt_login_salt
        r = Aws::Kms.new('login','user').decrypt(@manager_obj.authentication_salt)
        return r unless r.success?

        @authentication_salt_d = r.data[:plaintext]

        success
      end

      # Validate password
      #
      # * Author: Puneet
      # * Date: 15/01/2018
      # * Reviewed By:
      #
      # @return [Result::Base]
      #
      def validate_password

        evaluated_password_e = Manager.get_encrypted_password(@password, @authentication_salt_d)

        unless evaluated_password_e == @manager_obj.password
          manager = Manager.where(id: @manager_obj.id).first # we might have stale data as KMS lookup might take time or ?
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
      # * Author: Puneet
      # * Date: 15/01/2018
      # * Reviewed By:
      #
      # @return [Result::Base]
      #
      def update_manager

        @manager_obj.failed_login_attempt_count = 0
        @manager_obj.last_session_updated_at = current_timestamp
        @manager_obj.save!

        success

      end

      # Set cookie value
      #
      # * Author: Puneet
      # * Date: 15/01/2018
      # * Reviewed By:
      #
      # @return [Result::Base]
      #
      def set_cookie_value

        cookie_value = Manager.get_cookie_value(
            manager_id: @manager_obj.id,
            current_client_id: @manager_obj.current_client_id,
            token_s: @manager_obj.password,
            browser_user_agent: @browser_user_agent,
            last_session_updated_at: @manager_obj.last_session_updated_at,
            auth_level: GlobalConstant::Cookie.password_auth_prefix
        )

        success_with_data({cookie_value: cookie_value}, go_to: fetch_go_to)

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
        if !@manager_obj.send("#{GlobalConstant::Manager.has_verified_email_property}?")
          GlobalConstant::GoTo.verify_email
        elsif @manager_obj.send("#{GlobalConstant::Manager.has_setup_mfa_property}?")
          GlobalConstant::GoTo.authenticate_mfa
        elsif @client[:properties].include?(GlobalConstant::Client.has_enforced_mfa_property)
          GlobalConstant::GoTo.setup_mfa
        else
          GlobalConstant::GoTo.economy_planner_step_one
        end
      end

    end

  end

end
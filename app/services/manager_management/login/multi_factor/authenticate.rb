module ManagerManagement

  module Login

    module MultiFactor

      class Authenticate < ManagerManagement::Login::MultiFactor::Base

        # Initialize
        #
        # * Author: Puneet
        # * Date: 10/10/2017
        # * Reviewed By: 
        #
        # @params [String] password_auth_cookie_value (mandatory) - single auth cookie value
        # @params [String] otp (mandatory) - this is the Otp entered
        # @params [String] browser_user_agent (mandatory) - browser user agent
        #
        # @return [ManagerManagement::Login::MultiFactor::Authenticate]
        #
        def initialize(params)
          super
          @otp = @params[:otp].to_s
          @double_auth_cookie_value = nil
        end

        # Perform
        #
        # * Author: Puneet
        # * Date: 10/10/2017
        # * Reviewed By: 
        #
        # @return [Result::Base]
        #
        def perform

          handle_errors_and_exceptions do

            validate

            validate_password_auth_cookie

            fetch_manager

            fail OstCustomError.new unauthorized_access_response('am_l_ma_b_3') if @manager.mfa_token.blank?

            decrypt_authentication_salt

            decrypt_ga_secret

            validate_otp

            set_double_auth_cookie_value

            success_with_data(
                double_auth_cookie_value: @double_auth_cookie_value
            )

          end

        end

        private

        # Validate otp
        #
        # * Author: Puneet
        # * Date: 10/10/2017
        # * Reviewed By: 
        #
        # @return [Result::Base]
        #
        def validate_otp

          rotp_obj = Google::Authenticator.new(@ga_secret_d)
          r = rotp_obj.verify_with_drift_and_prior(@otp, @manager.last_session_updated_at)

          fail OstCustomError.new error_with_data(
                                      'am_l_ma_7',
                                      'something_went_wrong',
                                      GlobalConstant::ErrorAction.default,
                                      {}
                                  ) unless r.success?

          # Update last_otp_at
          @manager.last_session_updated_at = r.data[:verified_at_timestamp]
          @manager.send("set_#{GlobalConstant::Manager.has_setup_mfa_property}")
          @manager.save!

          success

        end

        # Set Double auth cookie
        #
        # * Author: Puneet
        # * Date: 10/10/2017
        # * Reviewed By: 
        #
        # Sets @double_auth_cookie_value
        #
        # @return [Result::Base]
        #
        def set_double_auth_cookie_value
          @double_auth_cookie_value = Manager.get_cookie_value(
              manager_id: @manager.id,
              current_client_id: @manager.current_client_id,
              token_s: @manager.mfa_token,
              browser_user_agent: @browser_user_agent,
              last_session_updated_at: @manager.last_session_updated_at,
              auth_level: GlobalConstant::Cookie.mfa_auth_prefix
          )

          success
        end

      end

    end

  end

end
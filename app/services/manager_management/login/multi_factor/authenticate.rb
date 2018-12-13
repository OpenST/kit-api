module ManagerManagement

  module Login

    module MultiFactor

      class Authenticate < ManagerManagement::Login::MultiFactor::Base

        # Initialize
        #
        # * Author: Puneet
        # * Date: 08/12/2018
        # * Reviewed By: 
        #
        # @params [String] manager_id (mandatory) - manager_id
        # @params [Hash] client (mandatory) - client of logged in manager
        # @params [String] otp (mandatory) - this is the Otp entered
        # @params [String] browser_user_agent (mandatory) - browser user agent
        #
        # @return [ManagerManagement::Login::MultiFactor::Authenticate]
        #
        def initialize(params)

          super

          @client = @params[:client]
          @browser_user_agent = @params[:browser_user_agent]
          @otp = @params[:otp].to_s

          @double_auth_cookie_value = nil

        end

        # Perform
        #
        # * Author: Puneet
        # * Date: 08/12/2018
        # * Reviewed By: 
        #
        # @return [Result::Base]
        #
        def perform

          handle_errors_and_exceptions do

            validate

            fetch_manager

            fail OstCustomError.new unauthorized_access_response('am_l_ma_b_3') if @manager_obj.mfa_token.blank?

            decrypt_authentication_salt

            decrypt_ga_secret

            validate_otp

            set_double_auth_cookie_value

            success_with_data(
                {double_auth_cookie_value: @double_auth_cookie_value},
                fetch_go_to
            )

          end

        end

        private

        # Validate otp
        #
        # * Author: Puneet
        # * Date: 08/12/2018
        # * Reviewed By: 
        #
        # @return [Result::Base]
        #
        def validate_otp

          rotp_obj = Google::Authenticator.new(@ga_secret_d)
          r = rotp_obj.verify_with_drift_and_prior(@otp, @manager_obj.last_session_updated_at)

          fail OstCustomError.new error_with_data(
                                      'am_l_ma_7',
                                      'something_went_wrong',
                                      GlobalConstant::ErrorAction.default,
                                      {}
                                  ) unless r.success?

          # Update last_otp_at
          @manager_obj.last_session_updated_at = r.data[:verified_at_timestamp]
          @manager_obj.send("set_#{GlobalConstant::Manager.has_setup_mfa_property}")
          @manager_obj.save!

          success

        end

        # Set Double auth cookie
        #
        # * Author: Puneet
        # * Date: 08/12/2018
        # * Reviewed By: 
        #
        # Sets @double_auth_cookie_value
        #
        # @return [Result::Base]
        #
        def set_double_auth_cookie_value
          @double_auth_cookie_value = Manager.get_cookie_value(
              manager_id: @manager_obj.id,
              current_client_id: @manager_obj.current_client_id,
              token_s: @manager_obj.mfa_token,
              browser_user_agent: @browser_user_agent,
              last_session_updated_at: @manager_obj.last_session_updated_at,
              auth_level: GlobalConstant::Cookie.mfa_auth_prefix
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
          GlobalConstant::GoTo.economy_planner_step_one
        end

      end

    end

  end

end
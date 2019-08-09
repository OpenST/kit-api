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
        # @params [String] cookie_value (mandatory) - cookie value
        #
        # @return [ManagerManagement::Login::MultiFactor::Authenticate]
        #
        def initialize(params)

          super

          @client = @params[:client]
          @browser_user_agent = @params[:browser_user_agent]
          @otp = @params[:otp].to_s
          @luse_cookie_value = @params[:luse_cookie_value]

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

            r = validate
            return r unless r.success?

            r = set_parts
            return r unless r.success?

            r = fetch_manager
            return r unless r.success?

            return unauthorized_access_response('am_l_ma_b_3') if @manager_obj.mfa_token.blank?

            r = handle_go_to
            return r unless r.success?

            r = decrypt_authentication_salt
            return r unless r.success?

            r = decrypt_ga_secret
            return r unless r.success?

            r = validate_otp
            return r unless r.success?

            r = validate_and_send_device_verification_mail
            return r unless r.success?

            r = set_double_auth_cookie_value
            return r unless r.success?

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
          r = rotp_obj.verify_with_drift_and_prior(@otp)

          unless r.success?
            @manager_obj.failed_mfa_attempt_count ||= 0
            @manager_obj.failed_mfa_attempt_count += 1


            if @manager_obj.failed_mfa_attempt_count >= 5
              @manager_obj.status = GlobalConstant::Manager.auto_blocked_status
              @manager_obj.save!

              return validation_error(
                  'mm_l_mf_a_1',
                  'invalid_api_params',
                  ['mfa_limit_reached'],
                  GlobalConstant::ErrorAction.default
              )
            end

            @manager_obj.save!
            return r
          end

          @manager_obj.failed_mfa_attempt_count = 0
          @manager_obj.last_session_updated_at = r.data[:verified_at_timestamp]

          @manager_obj.save!

          # Set mfa property atomically
          status_to_set = GlobalConstant::Manager.has_setup_mfa_property
          column_name, value = Manager.send("get_bit_details_for_#{status_to_set}")

          update_string = "#{column_name} = #{column_name} | #{value}"
          Manager.where(id: @manager_obj.id).update_all([update_string])

          Manager.deliberate_cache_flush(@manager_obj.id)

          @manager_obj[column_name] |= value

          success

        end

        # Send email for device verification if required
        #
        # * Author: Santhosh
        # * Date: 29/09/2019
        # * Reviewed By:
        #
        # @return [Result::Base]
        #
        def validate_and_send_device_verification_mail

          device = CacheManagement::ManagerDeviceById.new([@manager_device_id]).fetch[@manager_device_id]

          return unauthorized_access_response('mm_l_mf_a_7') if device.nil?

          @device_authorized = (device[:status] == GlobalConstant::ManagerDevice.authorized)

          BackgroundJob.enqueue(
              DeviceRegistrationJob,
              {
                  manager_id: @manager_obj.id,
                  manager_device_id: @manager_device_id
              }
          ) unless device[:status] == GlobalConstant::ManagerDevice.authorized

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

          device = CacheManagement::ManagerDeviceById.new([@manager_device_id]).fetch[@manager_device_id]

          return unauthorized_access_response('mm_l_mf_a_6') if device.nil?

          @double_auth_cookie_value = Manager.get_cookie_value(
              manager_id: @manager_obj.id,
              current_client_id: @manager_obj.current_client_id,
              token_s: @manager_obj.mfa_token,
              browser_user_agent: @browser_user_agent,
              fingerprint: device[:fingerprint],
              manager_device_id: @manager_device_id,
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
          # if company information not given, go to company information page
          unless @client[:properties].include?(GlobalConstant::Client.has_company_info_property)
            return GlobalConstant::GoTo.company_information
          end

          return GlobalConstant::GoTo.verify_device unless @device_authorized

          #check the luse cookie value here and redirect accordingly
          if @luse_cookie_value == GlobalConstant::Cookie.mainnet_env
            #redirect to mainnet token setup
            GlobalConstant::GoTo.mainnet_token_dashboard
          elsif @luse_cookie_value == GlobalConstant::Cookie.sandbox_env
            #redirect to testnet token setup
            GlobalConstant::GoTo.sandbox_token_dashboard
          else
            #redirect to token setup
            GlobalConstant::GoTo.token_dashboard
          end

        end

      end

    end

  end

end
module ManagerManagement

  module VerifyCookie

    class Base < ServicesBase

      # Initialize
      #
      # * Author: Puneet
      # * Date: 10/10/2017
      # * Reviewed By: 
      #
      # @params [String] cookie_value (mandatory) - this is the admin cookie value
      # @params [String] browser_user_agent (mandatory) - browser user agent
      #
      # @return [ManagerManagement::VerifyCookie::Base]
      #
      def initialize(params)
        super

        @cookie_value = @params[:cookie_value]
        @browser_user_agent = @params[:browser_user_agent]

        @manager = nil
        @manager_id = nil
        @created_ts = nil
        @extended_cookie_value = nil

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

          set_parts

          validate_token

          set_extended_cookie_value

          success_with_data(
            extended_cookie_value: @extended_cookie_value,
            manager_id: @manager_id,
            client_id: @manager[:current_client_id]
          )

        end

      end

      private

      # Set parts
      #
      # * Author: Puneet
      # * Date: 10/10/2017
      # * Reviewed By: 
      #
      # Sets @manager_id, @created_ts, @token
      #
      # @return [Result::Base]
      #
      def set_parts
        parts = @cookie_value.split(':')
        fail OstCustomError.new unauthorized_access_response('am_vc_1') unless parts.length == 4

        fail OstCustomError.new unauthorized_access_response('am_vc_2') unless parts[2] == auth_level

        @manager_id = parts[0].to_i
        fail OstCustomError.new unauthorized_access_response('am_vc_3') unless @manager_id > 0

        @created_ts = parts[1].to_i
        fail OstCustomError.new unauthorized_access_response('am_vc_4') unless @created_ts + valid_upto >= current_timestamp

        @token = parts[3]

        success
      end

      # Validate token
      #
      # * Author: Puneet
      # * Date: 10/10/2017
      # * Reviewed By: 
      #
      # @return [Result::Base]
      #
      def validate_token

        @manager = CacheManagement::Manager.new([@manager_id]).fetch[@manager_id]
        @manager_s = CacheManagement::ManagerSecure.new([@manager_id]).fetch[@manager_id]

        fail OstCustomError.new unauthorized_access_response('am_vc_5') unless @manager.present? &&
            (@manager[:status] == GlobalConstant::Manager.active_status)

        evaluated_token = Manager.get_cookie_token(
            manager_id: @manager_id,
            current_client_id: @manager[:current_client_id],
            token_s: token_s,
            browser_user_agent: @browser_user_agent,
            last_session_updated_at: @manager_s[:last_session_updated_at],
            cookie_creation_time: @created_ts,
            auth_level: auth_level
        )

        fail OstCustomError.new unauthorized_access_response('am_vc_6') unless (evaluated_token == @token)

        success

      end

      # Set Extended Cookie Value
      #
      # * Author:
      # * Date: 10/10/2017
      # * Reviewed By:
      #
      # @Sets @extended_cookie_value
      #
      def set_extended_cookie_value
        @extended_cookie_value = Manager.get_cookie_value(
            manager_id: @manager_id,
            current_client_id: @manager[:current_client_id],
            token_s: token_s,
            browser_user_agent: @browser_user_agent,
            last_session_updated_at: @manager_s[:last_session_updated_at],
            auth_level: auth_level
        )
      end

      # Unauthorized access response
      #
      # * Author: Alpesh
      # * Date: 15/01/2018
      # * Reviewed By:
      #
      # @param [String] err (mandatory) - err code
      # @param [String] display_text (optional) - display text
      #
      # @return [Result::Base]
      #
      def unauthorized_access_response(err)
        fail OstCustomError.new error_with_data(
                                    err,
                                    'unauthorized_access_response',
                                    GlobalConstant::ErrorAction.default
                                )
      end

      # Secure Token
      #
      # * Author: Puneet
      # * Date: 10/10/2017
      # * Reviewed By:
      #
      # @return [String]
      #
      def token_s
        fail 'sub-class to implement'
      end

      # Auth level
      #
      # * Author: Puneet
      # * Date: 10/10/2017
      # * Reviewed By: 
      #
      # @return [String]
      #
      def auth_level
        fail 'sub-class to implement'
      end

      # Valid upto
      #
      # * Author: Puneet
      # * Date: 10/10/2017
      # * Reviewed By: 
      #
      # @return [Time]
      #
      def valid_upto
        fail 'sub-class to implement'
      end

    end

  end

end
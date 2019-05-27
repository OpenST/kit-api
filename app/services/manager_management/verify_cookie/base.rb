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

        @client = nil
        @manager = nil
        @manager_s = nil
        @manager_id = nil
        @created_ts = nil
        @client_manager = nil
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

          r = validate
          return r unless r.success?

          r = set_parts
          return r unless r.success?

          r = validate_token
          return r unless r.success?

          r = fetch_client
          return r unless r.success?

          r = validate_client_manager
          return r unless r.success?

          r = set_extended_cookie_value
          return r unless r.success?

          success_with_data(
            extended_cookie_value: @extended_cookie_value,
            manager_id: @manager_id,
            manager: @manager,
            client_id: @manager[:current_client_id],
            client: @client,
            client_manager: @client_manager
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
        return unauthorized_access_response('am_vc_1') unless parts.length == 4
        return unauthorized_access_response('am_vc_2') unless parts[2] == auth_level

        @manager_id = parts[0].to_i
        return unauthorized_access_response('am_vc_3') unless @manager_id > 0

        @created_ts = parts[1].to_i
        return unauthorized_access_response('am_vc_4') unless @created_ts + valid_upto >= current_timestamp

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

        return unauthorized_access_response('am_vc_5') unless @manager.present? &&
            (@manager[:status] == GlobalConstant::Manager.active_status)

        return unauthorized_access_response('am_vc_10') if token_s.blank?

        evaluated_token = Manager.get_cookie_token(
            manager_id: @manager_id,
            current_client_id: @manager[:current_client_id],
            token_s: token_s,
            browser_user_agent: @browser_user_agent,
            is_device_authorized: GlobalConstant::Cookie.device_authorized_value,
            last_session_updated_at: @manager_s[:last_session_updated_at],
            cookie_creation_time: @created_ts,
            auth_level: auth_level
        )

        return unauthorized_access_response('am_vc_6') unless (evaluated_token == @token)

        success

      end

      # fetch client
      #
      # * Author: Puneet
      # * Date: 10/10/2017
      # * Reviewed By: Sunil
      #
      # @return [Result::Base]
      #
      def fetch_client
        response = Util::EntityHelper.fetch_and_validate_client(@manager[:current_client_id], 'am_vc_')
        return error_with_go_to(
            response.internal_id,
            response.general_error_identifier,
            GlobalConstant::GoTo.logout
        ) unless response.success?

        @client = response.data
        success
      end

      # Validate client manager
      #
      # * Author: Puneet
      # * Date: 10/10/2017
      # * Reviewed By:
      #
      # @return [Result::Base]
      #
      def validate_client_manager

        @client_manager = CacheManagement::ClientManager.new([@manager_id], {client_id: @manager[:current_client_id]}).fetch[@manager_id]
        return client_manager_not_associated_response('am_vc_11') if @client_manager.blank?

        privileges = @client_manager[:privileges]

        is_client_manager_active = Util::CommonValidator.is_active_admin?(privileges)

        return client_manager_not_associated_response('am_vc_12') unless is_client_manager_active

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
            is_device_authorized: GlobalConstant::Cookie.device_authorized_value,
            last_session_updated_at: @manager_s[:last_session_updated_at],
            auth_level: auth_level
        )

        success
      end

      # Unauthorized access response
      #
      # * Author: Puneet
      # * Date: 15/01/2018
      # * Reviewed By:
      #
      # @param [String] err (mandatory) - err code
      #
      # @return [Result::Base]
      #
      def unauthorized_access_response(err)
        error_with_data(
          err,
          'unauthorized_access_response',
          GlobalConstant::ErrorAction.default
        )
      end

      # no client associated response
      #
      # * Author: Puneet
      # * Date: 15/01/2018
      # * Reviewed By:
      #
      # @param [String] err (mandatory) - err code
      #
      # @return [Result::Base]
      #
      def no_client_associated_response(err)
        error_with_data(
          err,
          'no_client_associated',
          GlobalConstant::ErrorAction.default
        )
      end

      #  client manager not associated response
      #
      # * Author: Puneet
      # * Date: 15/01/2018
      # * Reviewed By:
      #
      # @param [String] err (mandatory) - err code
      #
      # @return [Result::Base]
      #
      def client_manager_not_associated_response(err)
        error_with_data(
          err,
          'client_manager_inactive',
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
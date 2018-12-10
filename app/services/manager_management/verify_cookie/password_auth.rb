module ManagerManagement

  module VerifyCookie

    class PasswordAuth < ManagerManagement::VerifyCookie::Base

      # Initialize
      #
      # * Author: Puneet
      # * Date: 10/10/2017
      # * Reviewed By:
      #
      # @params [String] cookie_value (mandatory) - this is the admin cookie value
      # @params [String] browser_user_agent (mandatory) - browser user agent
      #
      # @return [ManagerManagement::VerifyCookie::PasswordAuth]
      #
      def initialize(params)
        super
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
        super
      end

      private

      # Auth level
      #
      # * Author: Puneet
      # * Date: 10/10/2017
      # * Reviewed By:
      #
      # @return [String]
      #
      def auth_level
        GlobalConstant::Cookie.password_auth_prefix
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
        GlobalConstant::Cookie.password_auth_expiry
      end

    end

  end

end
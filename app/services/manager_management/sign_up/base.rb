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

      end

      private

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
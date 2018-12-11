module ManagerManagement

  class Logout < ServicesBase

    # Initialize
    #
    # * Author: Aniket
    # * Date: 21/09/2018
    # * Reviewed By:
    #
    # @param [String] cookie_value (mandatory) -  cookie
    # @param [String] browser_user_agent (mandatory) - browser user agent
    #
    # @return [ManagerManagement::Logout]
    #
    def initialize(params)
      
      super

      @cookie_value = @params[:cookie_value]
      @browser_user_agent = @params[:browser_user_agent]

      @manager_id = nil
      
    end

    # Perform
    #
    # * Author: Aniket
    # * Date: 21/09/2018
    # * Reviewed By:
    #
    def perform

      handle_errors_and_exceptions do

        verify_mfa_cookie

        logout_manager

        success

      end

    end

    private

    # Authenticate cookie
    #
    # * Author: Aniket
    # * Date: 21/09/2018
    # * Reviewed By:
    #
    def verify_mfa_cookie

      r = ManagerManagement::VerifyCookie::MultiFactorAuth.new(
          cookie_value: @cookie_value,
          browser_user_agent: @browser_user_agent
      ).perform

      unless r.success?
        r = ManagerManagement::VerifyCookie::PasswordAuth.new(
          cookie_value: @cookie_value,
          browser_user_agent: @browser_user_agent
        ).perform
        fail OstCustomError.new r unless r.success?
      end

      @manager_id = r.data[:manager_id]

      success
      
    end

    # Logout user
    #
    # * Author: Aniket
    # * Date: 21/09/2018
    # * Reviewed By:
    #
    def logout_manager

      manager = Manager.where(id: @manager_id).first
      manager.last_session_updated_at = current_timestamp
      manager.save!

      success

    end

  end

end

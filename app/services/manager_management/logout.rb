module ManagerManagement

  class Logout < ServicesBase

    # Initialize
    #
    # * Author: Aniket
    # * Date: 21/09/2018
    # * Reviewed By:
    #
    # @params [String] cookie_value (mandatory) -  cookie
    # @params [String] browser_user_agent (mandatory) - browser user agent
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

        r = verify_mfa_cookie
        return r unless r.success?

        r = logout_manager
        return r unless r.success?

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
       return r unless r.success?
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

      Manager.where(id: @manager_id).update_all(last_session_updated_at: current_timestamp)

      CacheManagement::ManagerSecure.new([@manager_id]).clear

      success

    end

  end

end

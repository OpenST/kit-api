class FetchGoTo

  # Initialize
  #
  # * Author: Puneet
  # * Date: 06/12/2018
  # * Reviewed By:
  #
  # @param [Hash] params (mandatory)
  #
  # @return [GoTo::ByManagerState]
  #
  def initialize(params)
    @is_password_auth_cookie_valid = params[:is_password_auth_cookie_valid]
    @is_multi_auth_cookie_valid = params[:is_multi_auth_cookie_valid]
    @client = params[:client]
    @manager = params[:manager]
    @client_manager = params[:client_manager]
  end

  # Perform
  #
  # * Author: Puneet
  # * Date: 06/12/2018
  # * Reviewed By:
  #
  # @return [Hash]
  #
  def fetch_by_manager_state

    handle_errors_and_exceptions do

      return GlobalConstant::GoTo.login unless @is_password_auth_cookie_valid

      return GlobalConstant::GoTo.verify_email if @manager[:properties].exclude?(GlobalConstant::Manager.has_verified_email_property)

      return fetch_by_economy_state if @is_multi_auth_cookie_valid

      if @manager[:properties].include?(GlobalConstant::Manager.has_setup_mfa_property)
        GlobalConstant::GoTo.authenticate_mfa
      elsif @client[:properties].include?(GlobalConstant::Client.has_enforced_mfa_property)
        GlobalConstant::GoTo.setup_mfa
      else
        fetch_by_economy_state
      end

    end

  end

  # Perform
  #
  # * Author: Puneet
  # * Date: 06/12/2018
  # * Reviewed By:
  #
  # @return [Hash]
  #
  def fetch_by_economy_state
    #TODO: Implement logic here
    handle_errors_and_exceptions do
      GlobalConstant::GoTo.economy_planner_step_one
    end
  end

end
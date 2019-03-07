class FetchGoTo < ServicesBase

  # Initialize
  #
  # * Author: Puneet
  # * Date: 06/12/2018
  # * Reviewed By:
  #
  # @param [Hash] params (mandatory)
  #
  # @return [FetchGoTo]
  #
  def initialize(params)

    super

    @is_password_auth_cookie_valid = @params[:is_password_auth_cookie_valid]
    @is_multi_auth_cookie_valid = @params[:is_multi_auth_cookie_valid]
    @client = @params[:client]
    @manager = @params[:manager]
    @client_manager = @params[:client_manager]
    @token = @params[:token]
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

      if @is_multi_auth_cookie_valid

        fetch_by_economy_state

      elsif @manager[:properties].include?(GlobalConstant::Manager.has_setup_mfa_property)

        GlobalConstant::GoTo.authenticate_mfa

      elsif @client[:properties].include?(GlobalConstant::Client.has_enforced_mfa_property)

        GlobalConstant::GoTo.setup_mfa

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
      GlobalConstant::GoTo.token_setup
    end
  end

end
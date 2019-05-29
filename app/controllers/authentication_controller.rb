class AuthenticationController < ApplicationController

  before_action :set_authentication_params_to_nil
  before_action :authenticate_by_mfa_cookie
  before_action :authenticate_sub_env_access

  private

  # clear all authentication related params (as we don't want to respect these values if sent by FE)
  #
  # * Author: Puneet
  # * Date: 07/12/2018
  # * Reviewed By: Sunil
  #
  def set_authentication_params_to_nil

    params[:is_multi_auth_cookie_valid] = false
    params[:is_password_auth_cookie_valid] = false

    params[:manager_id] = nil
    params[:manager] = nil
    params[:client_id] = nil
    params[:client] = nil
    params[:client_manager] = nil

  end

  # Authenticate request - verifies Password Auth cookie. if invalid log user out
  #
  # * Author: Puneet
  # * Date: 07/12/2018
  # * Reviewed By: Sunil
  #
  def authenticate_by_password_cookie

    cookie_verify_rsp = verify_password_cookie

    unless cookie_verify_rsp.success?
      handle_cookie_validation_failure(cookie_verify_rsp)
    end

  end

  # Authenticate request - verifies MFA Auth cookie. if invalid log user out
  #
  # * Author: Puneet
  # * Date: 07/12/2018
  # * Reviewed By: Sunil
  #
  def authenticate_by_mfa_cookie

    cookie_verify_rsp = verify_mfa_cookie
    return if cookie_verify_rsp.success?

    if cookie_verify_rsp.go_to == GlobalConstant::GoTo.login
      handle_cookie_validation_failure(cookie_verify_rsp)
    else
      render_api_response(cookie_verify_rsp)
    end

  end

  # Check if Password cookie is valid
  #
  # * Author: Puneet
  # * Date: 08/12/2018
  # * Reviewed By: Sunil
  #
  # @return [Result::Base]
  #
  def verify_password_cookie

    # We firstly verify the password cookie. If password cookie is present, we return.
    cookie_value = cookies[GlobalConstant::Cookie.user_cookie_name.to_sym]

    cookie_verify_rsp = ManagerManagement::VerifyCookie::PasswordAuth.new(
        cookie_value: cookie_value,
        browser_user_agent: http_user_agent
    ).perform

    if cookie_verify_rsp.success?

      handle_cookie_validation_success(cookie_verify_rsp, GlobalConstant::Cookie.password_auth_expiry.from_now)

      params[:is_multi_auth_cookie_valid] = false
      params[:is_password_auth_cookie_valid] = true

      # If password cookie is not present, we check for MFA cookie. We do this because sometimes a higher authenticated
      # manager might try to re-visit some page which only needs a password cookie. That manager won't have a password
      # cookie but would have a MFA cookie.
      #
    else

      cookie_verify_rsp = ManagerManagement::VerifyCookie::MultiFactorAuth.new(
          cookie_value: cookie_value,
          browser_user_agent: http_user_agent
      ).perform

      if cookie_verify_rsp.success?

        handle_cookie_validation_success(cookie_verify_rsp, GlobalConstant::Cookie.mfa_auth_expiry.from_now)

        params[:is_multi_auth_cookie_valid] = true
        params[:is_password_auth_cookie_valid] = true

      end

    end

    cookie_verify_rsp

  end

  # Authenticate request - verifies MFA cookie
  #
  # * Author: Puneet
  # * Date: 08/12/2018
  # * Reviewed By: Sunil
  #
  def verify_mfa_cookie

    cookie_verify_rsp = ManagerManagement::VerifyCookie::MultiFactorAuth.new(
      cookie_value: cookies[GlobalConstant::Cookie.user_cookie_name.to_sym],
      browser_user_agent: http_user_agent
    ).perform

    if cookie_verify_rsp.success?

      handle_cookie_validation_success(cookie_verify_rsp, GlobalConstant::Cookie.mfa_auth_expiry.from_now)

      params[:is_multi_auth_cookie_valid] = true
      params[:is_password_auth_cookie_valid] = true

      cookie_verify_rsp

    else
  
      password_cookie_verify_rsp = ManagerManagement::VerifyCookie::PasswordAuth.new(
        cookie_value: cookies[GlobalConstant::Cookie.user_cookie_name.to_sym],
        browser_user_agent: http_user_agent
      ).perform
  
      if password_cookie_verify_rsp.success?
        if password_cookie_verify_rsp.data[:manager][:properties].exclude?(GlobalConstant::Manager.has_verified_email_property)
          go_to = GlobalConstant::GoTo.verify_email
          return error_with_go_to('wc_vmfc_1', 'unauthorized_access_response', go_to)
        elsif password_cookie_verify_rsp.data[:manager][:properties].include?(GlobalConstant::Manager.has_setup_mfa_property)
          go_to = GlobalConstant::GoTo.authenticate_mfa
          return error_with_go_to('wc_vmfc_2', 'unauthorized_access_response', go_to)
        elsif password_cookie_verify_rsp.data[:client][:properties].include?(GlobalConstant::Client.has_enforced_mfa_property)
          go_to = GlobalConstant::GoTo.setup_mfa
          return error_with_go_to('wc_vmfc_3', 'mfa_mandatory_for_client', go_to)
        end

        handle_cookie_validation_success(password_cookie_verify_rsp,
                                         GlobalConstant::Cookie.password_auth_expiry.from_now)

        params[:is_multi_auth_cookie_valid] = false
        params[:is_password_auth_cookie_valid] = true
        
        return password_cookie_verify_rsp
  
      else
  
        go_to = GlobalConstant::GoTo.login
        return error_with_go_to('wc_vmfc_4', 'unauthorized_access_response', go_to)
        
      end
      
    end

  end

  # Check if client is white listed
  #
  # * Author: Ankit
  # * Date: 30/01/2019
  # * Reviewed By: Sunil
  #
  def authenticate_sub_env_access
    if GlobalConstant::Base.main_sub_environment?
      client_env_statuses = params[:client][:mainnet_statuses]
      allowed_status = GlobalConstant::Client.mainnet_whitelisted_status
      error_go_to = GlobalConstant::GoTo.sandbox_token_dashboard
    else
      client_env_statuses = params[:client][:sandbox_statuses]
      allowed_status = GlobalConstant::Client.sandbox_whitelisted_status
      error_go_to = GlobalConstant::GoTo.logout
    end

    if client_env_statuses.exclude?(allowed_status)
      service_response = error_with_go_to('a_c_ac_1', 'unauthorized_to_perform_action', error_go_to)
      return render_api_response(service_response)
    end
  end

  # Handle cookie validation success response
  # 1. set cookie
  # 2. set authenticated param in params hash
  # 3. remove autentication related critical data to sent in response
  #
  # * Author: Puneet
  # * Date: 04/03/2019
  # * Reviewed By: Sunil
  #
  def handle_cookie_validation_success(cookie_verify_rsp, cookie_expiry)

    # set cookie
    extended_cookie_value = cookie_verify_rsp.data[:extended_cookie_value]
    set_cookie(
        GlobalConstant::Cookie.user_cookie_name,
        extended_cookie_value,
        cookie_expiry
    ) if extended_cookie_value.present?

    # set authenticated param in params hash
    params[:manager_id] = cookie_verify_rsp.data[:manager_id]
    params[:manager] = cookie_verify_rsp.data[:manager]
    params[:manager_device_id] = cookie_verify_rsp.data[:manager_device_id]
    params[:client_id] = cookie_verify_rsp.data[:client_id]
    params[:client] = cookie_verify_rsp.data[:client]
    params[:client_manager] = cookie_verify_rsp.data[:client_manager]

    # Remove sensitive data
    cookie_verify_rsp.data = {}

  end

  # Handle cookie validation failure response
  #
  # 1. delete cookie
  # 3. remove authentication related critical data to sent in response
  #
  # * Author: Puneet
  # * Date: 04/03/2019
  # * Reviewed By: Sunil
  #
  def handle_cookie_validation_failure(cookie_verify_rsp)

    # Clear cookie
    delete_cookie(GlobalConstant::Cookie.user_cookie_name)

    # Set 401 header
    cookie_verify_rsp.go_to = GlobalConstant::GoTo.login
    cookie_verify_rsp.http_code = GlobalConstant::ErrorCode.unauthorized_access

    cookie_verify_rsp.data = {}

    return render_api_response(cookie_verify_rsp)

  end

end

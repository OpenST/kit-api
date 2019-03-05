class WebController < ApplicationController

  # Load extra libraries not present in API mode setup
  [
      ActionController::Cookies
  ].each do |mdl|
    include mdl
  end

  # Added CSRF token from header
  before_action :append_csrf_token_in_params

  # Check CSRF. Disable it for local postman testing.
  include ActionController::RequestForgeryProtection
  protect_from_forgery with: :exception
  include CsrfTokenConcern

  before_action :set_authentication_params_to_nil
  before_action :verify_mfa_cookie

  private

  # Set cookie
  #
  # * Author: Puneet
  # * Date: 07/12/2018
  # * Reviewed By: Sunil
  #
  # @params [String] cookie_name (mandatory)
  # @params [String] value (mandatory)
  # @params [Time] expires (mandatory)
  #
  def set_cookie(cookie_name, value, expires)
    cookies[cookie_name.to_sym] = {
        value: value,
        expires: expires,
        domain: GlobalConstant::Base.cookie_domain,
        http_only: true,
        secure: Rails.env.production?,
        same_site: :strict
    }
  end

  # Delete cookie
  #
  # * Author: Puneet
  # * Date: 07/12/2018
  # * Reviewed By: Sunil
  #
  # @params [String] cookie_name (mandatory)
  #
  def delete_cookie(cookie_name)
    cookies.delete(
      cookie_name.to_sym,
      domain: GlobalConstant::Base.cookie_domain,
      secure: Rails.env.production?,
      same_site: :strict
    )
  end

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
  def mandatory_verify_password_cookie

    cookie_verify_rsp = verify_password_cookie

    unless cookie_verify_rsp.success?
      handle_cookie_validation_failure(cookie_verify_rsp)
    end

  end

  # Authenticate request - verifies Password Auth cookie. if valid set vars accordingly else do nothing. DO NOT return error
  #
  # * Author: Puneet
  # * Date: 07/12/2018
  # * Reviewed By: Sunil
  #
  def optional_verify_password_cookie
    verify_password_cookie
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

    mfa_cookie_verify_rsp = ManagerManagement::VerifyCookie::MultiFactorAuth.new(
      cookie_value: cookies[GlobalConstant::Cookie.user_cookie_name.to_sym],
      browser_user_agent: http_user_agent
    ).perform

    if mfa_cookie_verify_rsp.success?

      handle_cookie_validation_success(mfa_cookie_verify_rsp, GlobalConstant::Cookie.mfa_auth_expiry.from_now)

      params[:is_multi_auth_cookie_valid] = true
      params[:is_password_auth_cookie_valid] = true

    else

      handle_cookie_validation_failure(mfa_cookie_verify_rsp)

      # NOTE: Commenting this piece of code for now. Check with Sunil before opening this

      # password_cookie_verify_rsp = ManagerManagement::VerifyCookie::PasswordAuth.new(
      #     cookie_value: cookies[GlobalConstant::Cookie.user_cookie_name.to_sym],
      #     browser_user_agent: http_user_agent
      # ).perform
      #
      # if password_cookie_verify_rsp.success?
      #
      #   handle_cookie_validation_success(password_cookie_verify_rsp, GlobalConstant::Cookie.password_auth_expiry.from_now)
      #
      #   params[:is_multi_auth_cookie_valid] = false
      #   params[:is_password_auth_cookie_valid] = true
      #
      #   if params[:manager][:properties].exclude?(GlobalConstant::Manager.has_verified_email_property)
      #     go_to = GlobalConstant::GoTo.verify_email
      #     render_api_response(error_with_go_to('wc_vmfc_1', 'unauthorized_access_response', go_to)) and return
      #   elsif params[:manager][:properties].include?(GlobalConstant::Manager.has_setup_mfa_property)
      #     go_to = GlobalConstant::GoTo.authenticate_mfa
      #     render_api_response(error_with_go_to('wc_vmfc_2', 'unauthorized_access_response', go_to)) and return
      #   elsif params[:client][:properties].include?(GlobalConstant::Client.has_enforced_mfa_property)
      #     go_to = GlobalConstant::GoTo.setup_mfa
      #     render_api_response(error_with_go_to('wc_vmfc_3', 'unauthorized_access_response', go_to)) and return
      #   end
      #
      # else
      #
      #   handle_cookie_validation_failure(mfa_cookie_verify_rsp)
      #
      # end

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

    render_api_response(cookie_verify_rsp)

  end

  # Try to assign authenticity_token from headers, if not sent in params
  #
  # * Author: Puneet
  # * Date: 07/12/2018
  # * Reviewed By: Sunil
  #
  def append_csrf_token_in_params
    params[:authenticity_token] ||= request.headers.env['HTTP_X_CSRF_TOKEN']
  end

  # Verifies if the request is xhr
  #
  # * Author: Ankit
  # * Date: 05/02/2019
  # * Reviewed By: Puneet
  #
  def verify_is_xhr

    if request.xhr?.nil?
      error_response = error_with_data(
        'a_c_dc_1',
        'request_not_xhr',
        GlobalConstant::ErrorAction.default
      )
      render_api_response(error_response)
    end

  end

end

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

  before_action :verify_mfa_cookie

  # Set cookie
  #
  # * Author: Puneet
  # * Date: 07/12/2018
  # * Reviewed By:
  #
  # @params [String] cookie_name (mandatory)
  # @params [String] value (mandatory)
  # @params [Time] expires (mandatory)
  #
  def set_cookie(cookie_name, value, expires)
    cookies[cookie_name.to_sym] = {
        value: value,
        expires: expires,
        domain: :all, #TODO: Domain specific
        http_only: true,
        secure: Rails.env.production?,
        same_site: :strict
    }
  end

  # Delete cookie
  #
  # * Author: Puneet
  # * Date: 07/12/2018
  # * Reviewed By:
  #
  # @params [String] cookie_name (mandatory)
  #
  def delete_cookie(cookie_name)
    cookies.delete(
      cookie_name.to_sym,
      domain: :all, #TODO: Domain specific
      secure: Rails.env.production?,
      same_site: :strict
    )
  end

  private

  # Authenticate request - verifies Password Auth cookie
  #
  # * Author: Puneet
  # * Date: 07/12/2018
  # * Reviewed By:
  #
  def verify_password_cookie

    # We firstly verify the password cookie. If password cookie is present, we return.
    cookie_value = cookies[GlobalConstant::Cookie.user_cookie_name.to_sym]

    password_cookie_verify_rsp = ManagerManagement::VerifyCookie::PasswordAuth.new(
        cookie_value: cookie_value,
        browser_user_agent: http_user_agent
    ).perform

    if password_cookie_verify_rsp.success?

      # Update Cookie, if required
      extended_cookie_value = password_cookie_verify_rsp.data[:extended_cookie_value]
      set_cookie(
          GlobalConstant::Cookie.user_cookie_name,
          extended_cookie_value,
          GlobalConstant::Cookie.password_auth_expiry.from_now
      ) if extended_cookie_value.present?

      params[:manager_id] = password_cookie_verify_rsp.data[:manager_id]
      params[:manager] = password_cookie_verify_rsp.data[:manager]
      params[:client_id] = password_cookie_verify_rsp.data[:client_id]
      params[:client] = password_cookie_verify_rsp.data[:client]
      params[:client_manager] = password_cookie_verify_rsp.data[:client_manager]
      params[:is_multi_auth_cookie_valid] = false
      params[:is_password_auth_cookie_valid] = true

      # Remove sensitive data
      password_cookie_verify_rsp.data = {}

    # If password cookie is not present, we check for MFA cookie. We do this because sometimes a higher authenticated
    # manager might try to re-visit some page which only needs a password cookie. That manager won't have a password
    # cookie but would have a MFA cookie.
    else

      mfa_cookie_verify_rsp = ManagerManagement::VerifyCookie::MultiFactorAuth.new(
          cookie_value: cookie_value,
          browser_user_agent: http_user_agent
      ).perform

      if mfa_cookie_verify_rsp.success?

        # Update Cookie, if required
        extended_cookie_value = mfa_cookie_verify_rsp.data[:extended_cookie_value]
        set_cookie(
            GlobalConstant::Cookie.user_cookie_name,
            extended_cookie_value,
            GlobalConstant::Cookie.mfa_auth_expiry.from_now
        ) if extended_cookie_value.present?

        params[:manager_id] = mfa_cookie_verify_rsp.data[:manager_id]
        params[:manager] = mfa_cookie_verify_rsp.data[:manager]
        params[:client_id] = mfa_cookie_verify_rsp.data[:client_id]
        params[:client] = mfa_cookie_verify_rsp.data[:client]
        params[:client_manager] = mfa_cookie_verify_rsp.data[:client_manager]
        params[:is_multi_auth_cookie_valid] = true
        params[:is_password_auth_cookie_valid] = true

        # Remove sensitive data
        mfa_cookie_verify_rsp.data = {}

      else

        # Clear cookie
        delete_cookie(GlobalConstant::Cookie.user_cookie_name)
        # Set 401 header
        password_cookie_verify_rsp.http_code = GlobalConstant::ErrorCode.unauthorized_access
        password_cookie_verify_rsp.go_to = GlobalConstant::GoTo.login
        render_api_response(password_cookie_verify_rsp)

      end

    end

  end

  # Authenticate request - verifies MFA cookie
  #
  # * Author: Puneet
  # * Date: 08/12/2018
  # * Reviewed By:
  #
  def verify_mfa_cookie

    mfa_cookie_verify_rsp = ManagerManagement::VerifyCookie::MultiFactorAuth.new(
      cookie_value: cookies[GlobalConstant::Cookie.user_cookie_name.to_sym],
      browser_user_agent: http_user_agent
    ).perform

    if mfa_cookie_verify_rsp.success?

      # Update Cookie, if required
      extended_cookie_value = mfa_cookie_verify_rsp.data[:extended_cookie_value]
      set_cookie(
        GlobalConstant::Cookie.user_cookie_name,
        extended_cookie_value,
        GlobalConstant::Cookie.mfa_auth_expiry.from_now
      ) if extended_cookie_value.present?

      params[:manager_id] = mfa_cookie_verify_rsp.data[:manager_id]
      params[:manager] = mfa_cookie_verify_rsp.data[:manager]
      params[:client_id] = mfa_cookie_verify_rsp.data[:client_id]
      params[:client] = mfa_cookie_verify_rsp.data[:client]
      params[:client_manager] = mfa_cookie_verify_rsp.data[:client_manager]
      params[:is_multi_auth_cookie_valid] = true
      params[:is_password_auth_cookie_valid] = true

      # Remove sensitive data
      mfa_cookie_verify_rsp.data = {}

    else

      password_cookie_verify_rsp = ManagerManagement::VerifyCookie::PasswordAuth.new(
          cookie_value: cookies[GlobalConstant::Cookie.user_cookie_name.to_sym],
          browser_user_agent: http_user_agent
      ).perform

      if password_cookie_verify_rsp.success?

        params[:manager_id] = password_cookie_verify_rsp.data[:manager_id]
        params[:manager] = password_cookie_verify_rsp.data[:manager]
        params[:client_id] = password_cookie_verify_rsp.data[:client_id]
        params[:client] = password_cookie_verify_rsp.data[:client]
        params[:client_manager] = password_cookie_verify_rsp.data[:client_manager]
        params[:is_multi_auth_cookie_valid] = false
        params[:is_password_auth_cookie_valid] = true

        if params[:manager][:properties].exclude?(GlobalConstant::Manager.has_verified_email_property)
          go_to = GlobalConstant::GoTo.verify_email
          render_api_response(error_with_go_to('wc_vmfc_1', 'unauthorized_access_response', go_to)) and return
        elsif params[:manager][:properties].include?(GlobalConstant::Manager.has_setup_mfa_property)
          go_to = GlobalConstant::GoTo.authenticate_mfa
          render_api_response(error_with_go_to('wc_vmfc_2', 'unauthorized_access_response', go_to)) and return
        elsif password_cookie_verify_rsp.data[:client][:properties].include?(GlobalConstant::Client.has_enforced_mfa_property)
          go_to = GlobalConstant::GoTo.setup_mfa
          render_api_response(error_with_go_to('wc_vmfc_3', 'unauthorized_access_response', go_to)) and return
        end

        extended_cookie_value = password_cookie_verify_rsp.data[:extended_cookie_value]
        set_cookie(
            GlobalConstant::Cookie.user_cookie_name,
            extended_cookie_value,
            GlobalConstant::Cookie.password_auth_expiry.from_now
        ) if extended_cookie_value.present?

        # Remove sensitive data
        password_cookie_verify_rsp.data = {}

      else

        # Clear cookie
        delete_cookie(GlobalConstant::Cookie.user_cookie_name)
        # Set 401 header
        mfa_cookie_verify_rsp.go_to = GlobalConstant::GoTo.login
        mfa_cookie_verify_rsp.http_code = GlobalConstant::ErrorCode.unauthorized_access
        render_api_response(mfa_cookie_verify_rsp)

      end

    end

  end

  # Try to assign authenticity_token from headers, if not sent in params
  #
  # * Author: Puneet
  # * Date: 07/12/2018
  # * Reviewed By:
  #
  def append_csrf_token_in_params
    params[:authenticity_token] ||= request.headers.env['HTTP_X_CSRF_TOKEN']
  end

end

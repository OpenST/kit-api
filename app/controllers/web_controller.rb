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
  # * Date: 24/01/2018
  # * Reviewed By: Puneet
  #
  # @params [String] cookie_name (mandatory)
  # @params [String] value (mandatory)
  # @params [Time] expires (mandatory)
  #
  def set_cookie(cookie_name, value, expires)
    cookies[cookie_name.to_sym] = {
        value: value,
        expires: expires,
        domain: :all,
        http_only: true,
        secure: Rails.env.production?,
        same_site: :strict
    }
  end

  # Delete cookie
  #
  # * Author: Puneet
  # * Date: 24/01/2018
  # * Reviewed By: Puneet
  #
  # @params [String] cookie_name (mandatory)
  #
  def delete_cookie(cookie_name)
    cookies.delete(cookie_name.to_sym, domain: :all, secure: Rails.env.production?, same_site: :strict)
  end

  private

  # Authenticate request - verifies Password Auth cookie
  #
  # * Author: Puneet
  # * Date: 08/12/2018
  # * Reviewed By:
  #
  def verify_password_cookie

    password_cookie_verify_rsp = ManagerManagement::VerifyCookie::PasswordAuth.new(
        cookie_value: cookies[GlobalConstant::Cookie.user_cookie_name.to_sym],
        browser_user_agent: http_user_agent
    ).perform

    if password_cookie_verify_rsp.success?

      # Update Cookie, if required
      extended_cookie_value = password_cookie_verify_rsp.data[:extended_cookie_value]
      set_cookie(
          GlobalConstant::Cookie.user_cookie_name,
          extended_cookie_value,
          GlobalConstant::Cookie.mfa_auth_expiry.from_now
      ) if extended_cookie_value.present?

      params[:manager_id] = password_cookie_verify_rsp.data[:manager_id]
      params[:manager] = password_cookie_verify_rsp.data[:manager]
      params[:client_id] = password_cookie_verify_rsp.data[:client_id]
      params[:client] = password_cookie_verify_rsp.data[:client]
      params[:client_manager] = password_cookie_verify_rsp.data[:client_manager]

      # Remove sensitive data
      password_cookie_verify_rsp.data = {}

    else

      # Clear cookie
      delete_cookie(GlobalConstant::Cookie.user_cookie_name)
      # Set 401 header
      password_cookie_verify_rsp.http_code = GlobalConstant::ErrorCode.unauthorized_access
      render_api_response(password_cookie_verify_rsp)

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

      # Remove sensitive data
      mfa_cookie_verify_rsp.data = {}

    else

      password_cookie_verify_rsp = ManagerManagement::VerifyCookie::PasswordAuth.new(
          cookie_value: cookies[GlobalConstant::Cookie.user_cookie_name.to_sym],
          browser_user_agent: http_user_agent
      ).perform

      if password_cookie_verify_rsp.success?

        client_properties = password_cookie_verify_rsp.data[:client][:properties]

        # if client had enforced mfa and user is accessing something which requires mfa auth, redirect to mfa auth screen
        if client_properties.present? &&
            Client.get_bits_set_for_properties(client_properties).include?(GlobalConstant::Client.has_enforced_mfa_property)

          redirect_to :mfa and return

        end

        # Remove sensitive data
        password_cookie_verify_rsp.data = {}

      else

        # Clear cookie
        delete_cookie(GlobalConstant::Cookie.user_cookie_name)
        # Set 401 header
        mfa_cookie_verify_rsp.http_code = GlobalConstant::ErrorCode.unauthorized_access
        render_api_response(mfa_cookie_verify_rsp)

      end

    end

  end

  # Try to assign authenticity_token from headers, if not sent in params
  #
  # * Author: Puneet
  # * Date: 12/02/2018
  # * Reviewed By: Puneet
  #
  def append_csrf_token_in_params
    params[:authenticity_token] ||= request.headers.env['HTTP_X_CSRF_TOKEN']
  end

end

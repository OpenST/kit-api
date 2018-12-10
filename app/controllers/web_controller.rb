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
  unless GlobalConstant::Base.postman_testing?
    include ActionController::RequestForgeryProtection
    protect_from_forgery with: :exception
    include CsrfTokenConcern
  end

  before_action :authenticate_request

  # Set cookie
  #
  # * Author: Puneet
  # * Date: 24/01/2018
  # * Reviewed By: Aman
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
  # * Reviewed By: Aman
  #
  # @params [String] cookie_name (mandatory)
  #
  def delete_cookie(cookie_name)
    cookies.delete(cookie_name.to_sym, domain: :all, secure: Rails.env.production?, same_site: :strict)
  end

  private

  # Authenticate request - verifies cookie
  #
  # * Author: Puneet
  # * Date: 24/01/2018
  # * Reviewed By: Aman
  #
  def authenticate_request

    service_response = ManagerManagement::VerifyCookie.new(
      cookie_value: cookies[GlobalConstant::Cookie.user_cookie_name.to_sym],
      browser_user_agent: http_user_agent
    ).perform

    if service_response.success?
      # Update Cookie, if required
      extended_cookie_value = service_response.data[:extended_cookie_value]
      set_cookie(
        GlobalConstant::Cookie.user_cookie_name,
        extended_cookie_value,
        GlobalConstant::Cookie.user_expiry.from_now
      ) if extended_cookie_value.present?

      params[:manager_id] = service_response.data[:manager_id]
      params[:client_id] = service_response.data[:client_id]
      params[:client_token_id] = service_response.data[:client_token_id]

      # Remove sensitive data
      service_response.data = {}
    else
      # Clear cookie
      delete_cookie(GlobalConstant::Cookie.user_cookie_name)
      # Set 401 header
      service_response.http_code = GlobalConstant::ErrorCode.unauthorized_access
      render_api_response(service_response)
    end
  end

  # Try to assign authenticity_token from headers, if not sent in params
  #
  # * Author: Puneet
  # * Date: 12/02/2018
  # * Reviewed By: Aman
  #
  def append_csrf_token_in_params
    params[:authenticity_token] ||= request.headers.env['HTTP_X_CSRF_TOKEN']
  end

end

class Access::LoginController < Access::BaseController

  before_action :verify_recaptcha

  # Login Via Password
  #
  # * Author: Puneet
  # * Date: 08/12/2018
  # * Reviewed By: Sunil
  #
  def password_auth

    service_response = ManagerManagement::Login::PasswordAuth.new(params).perform

    if service_response.success?
      # NOTE: delete cookie value from data
      cookie_value = service_response.data.delete(:cookie_value)
      set_cookie(
          GlobalConstant::Cookie.user_cookie_name,
          cookie_value,
          GlobalConstant::Cookie.password_auth_expiry.from_now
      )
    end

    render_api_response(service_response)

  end

end

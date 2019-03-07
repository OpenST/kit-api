class Access::VerifyEmailController < AuthenticationController

  skip_before_action :authenticate_by_mfa_cookie
  skip_before_action :authenticate_sub_env_access

  before_action :authenticate_by_password_cookie, except: [:verify_email]

  # Email verification of user
  #
  # * Author: Puneet
  # * Date: 15/01/2018
  # * Reviewed By: Sunil
  #
  def verify_email

    cookie_verify_response = verify_password_cookie
    params[:is_logged_in_manager] = cookie_verify_response.success? ? 1 : 0

    service_response = ManagerManagement::DoubleOptIn.new(params).perform
    render_api_response(service_response)

  end

  # Send Email Verification Link
  #
  # * Author: Puneet
  # * Date: 15/02/2018
  # * Reviewed By: Sunil
  #
  def send_verify_email_link
    service_response = ManagerManagement::SendDoubleOptInLink.new(params).perform
    render_api_response(service_response)
  end

end

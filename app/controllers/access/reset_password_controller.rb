class Access::ResetPasswordController < Access::BaseController

  before_action :verify_recaptcha, only: [:send_reset_password_link]

  # Send Reset Password link
  #
  # * Author: Puneet
  # * Date: 15/01/2018
  # * Reviewed By: Sunil
  #
  def send_reset_password_link
    service_response = ManagerManagement::SendResetPasswordLink.new(params).perform
    render_api_response(service_response)
  end

  # Reset Password
  #
  # * Author: Puneet
  # * Date: 15/01/2018
  # * Reviewed By: sunil
  #
  def reset_password
    service_response = ManagerManagement::ResetPassword.new(params).perform
    render_api_response(service_response)
  end

end

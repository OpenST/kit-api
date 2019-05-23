class Access::VerifyDeviceController < AuthenticationController

  skip_before_action :authenticate_by_mfa_cookie
  skip_before_action :authenticate_sub_env_access

  #before_action :authenticate_by_password_cookie, except: [:verify_email]

  # Device verification of user
  #
  # * Author: Ankit
  # * Date: 22/05/2019
  # * Reviewed By:
  #
  def verify_device

    cookie_verify_response = verify_password_cookie
    params[:is_logged_in_manager] = cookie_verify_response.success? ? 1 : 0

    service_response = ManagerManagement::DeviceVerification.new(params).perform
    return render_api_response(service_response)

  end

end

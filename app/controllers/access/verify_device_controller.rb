class Access::VerifyDeviceController < AuthenticationController

  skip_before_action :authenticate_by_mfa_cookie
  skip_before_action :authenticate_sub_env_access

  before_action :authenticate_by_password_cookie, except: [:verify_device]

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

    if service_response.success? && params[:is_logged_in_manager] && params[:d_t].present?
      set_cookie(
        GlobalConstant::Cookie.device_verification_toast_cookie_name,
        '1',
        GlobalConstant::Cookie.device_verification_toast_expiry.from_now
      )
    end

    return render_api_response(service_response)

  end

  # Send Device Verification Link
  #
  # * Author: Ankit
  # * Date: 28/05/2018
  # * Reviewed By:
  #
  def send_verify_device_link
    service_response = ManagerManagement::SendDeviceVerificationLink.new(params).perform
    return render_api_response(service_response)
  end

end

class Access::VerifySdaController < AuthenticationController

  skip_before_action :authenticate_by_mfa_cookie
  skip_before_action :authenticate_sub_env_access

  before_action :authenticate_by_password_cookie, except: [:verify_secure_data_access]

  # Verify secure data access link
  #
  # * Author: Dhananjay
  # * Date: 01/06/2019
  # * Reviewed By:
  #
  def verify_secure_data_access
    cookie_verify_response = verify_password_cookie
    params[:is_logged_in_manager] = cookie_verify_response.success? ? 1 : 0
    service_response = DeveloperManagement::SecureDataAccessVerification.new(params).perform
    return render_api_response(service_response)
  end

  # Send Device Verification Link
  #
  # * Author: Dhananjay
  # * Date: 01/06/2019
  # * Reviewed By:
  #
  def send_secure_data_access_link
    service_response = DeveloperManagement::SendSecureDataAccessLink.new(params).perform
    return render_api_response(service_response)
  end

end

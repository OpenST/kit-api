class Access::LogoutController < AuthenticationController

  skip_before_action :authenticate_by_mfa_cookie
  skip_before_action :authenticate_sub_env_access

  before_action :authenticate_by_password_cookie

  # Logout
  #
  # * Author: Puneet
  # * Date: 29/01/2018
  # * Reviewed By: Sunil
  #
  def logout
    service_response = ManagerManagement::Logout.new(params).perform
    # delete cookie irrespective if service response was success
    delete_cookie(GlobalConstant::Cookie.user_cookie_name)
    delete_cookie(GlobalConstant::Cookie.secure_data_access_cookie_name)
    return render_api_response(service_response)
  end

end

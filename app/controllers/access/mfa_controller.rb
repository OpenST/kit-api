class Access::MfaController < AuthenticationController

  skip_before_action :authenticate_by_mfa_cookie
  skip_before_action :authenticate_sub_env_access

  before_action :authenticate_by_password_cookie

  # Get MFA Page details
  #
  # * Author: Puneet
  # * Date: 08/12/2018
  # * Reviewed By: Sunil
  #
  def mfa
    params[:cookie_value] = cookies[GlobalConstant::Cookie.user_cookie_name.to_sym]
    service_response = ManagerManagement::Login::MultiFactor::GetMfaUrl.new(params).perform
    return render_api_response(service_response)
  end

  # Perform MFA
  #
  # * Author: Puneet
  # * Date: 08/12/2018
  # * Reviewed By: Sunil
  #
  def multi_factor_auth
    params[:cookie_value] = cookies[GlobalConstant::Cookie.user_cookie_name.to_sym]
    params[:luse_cookie_value] = cookies[GlobalConstant::Cookie.last_used_env_cookie_name.to_sym]
    service_response = ManagerManagement::Login::MultiFactor::Authenticate.new(params).perform

    if service_response.success?
      # NOTE: delete cookie value from data
      cookie_value = service_response.data.delete(:double_auth_cookie_value)
      set_cookie(
          GlobalConstant::Cookie.user_cookie_name,
          cookie_value,
          GlobalConstant::Cookie.mfa_auth_expiry.from_now
      )
    end

    return render_api_response(service_response)

  end

end

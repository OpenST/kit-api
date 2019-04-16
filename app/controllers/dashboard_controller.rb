class DashboardController < AuthenticationController

  # Whitelisting
  #
  # * Author: Alpesh
  # * Date: 6/03/2019
  # * Reviewed By: Kedar
  #
  def get
    service_response = DashboardManagement::Get.new(params).perform

    # set last used env cookie
    set_cookie(
      GlobalConstant::Cookie.last_used_env_cookie_name,
      GlobalConstant::Base.main_sub_environment? ? GlobalConstant::Cookie.mainnet_env : GlobalConstant::Cookie.sandbox_env,
      GlobalConstant::Cookie.last_used_env_cookie_expiry
    )
    return render_api_response(service_response)
  end

end
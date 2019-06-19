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

  # Whitelisting
  #
  # * Author: Dhananjay
  # * Date: 19/06/2019
  # * Reviewed By: Kedar
  #
  def get_graphs_data
    service_response = DashboardManagement::GetGraphsData.new(params).perform

    if service_response.success?
      render :json => service_response.data
    elsif
      service_response.http_code = 404
      render_api_response(service_response)
    end
  end

end
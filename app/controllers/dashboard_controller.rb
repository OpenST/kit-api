class DashboardController < AuthenticationController

  # Whitelisting
  #
  # * Author: Alpesh
  # * Date: 6/03/2019
  # * Reviewed By: Kedar
  #
  def get
    service_response = DashboardManagement::Get.new(params).perform
    render_api_response(service_response)
  end

end
class DashboardController < WebController

  # Whitelisting
  #
  # * Author: Alpesh
  # * Date: 6/03/2019
  # * Reviewed By:
  #
  def get
    service_response = DashboardManagement::Get.new(params).perform
    render_api_response(service_response)
  end

end
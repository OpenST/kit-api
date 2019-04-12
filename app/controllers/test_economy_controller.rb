class TestEconomyController < AuthenticationController

  # Get Demo Details
  #
  # * Author: Puneet
  # * Date: 10/04/2019
  # * Reviewed By: Sunil
  #
  def get
    service_response = TestEconomyManagement::Get.new(params).perform
    return render_api_response(service_response)
  end

  # Activate
  #
  # * Author: Puneet
  # * Date: 10/04/2019
  # * Reviewed By: Sunil
  #
  def activate
    service_response = TestEconomyManagement::Activate.new(params).perform
    return render_api_response(service_response)
  end

end
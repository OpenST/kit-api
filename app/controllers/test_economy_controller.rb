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

  # Invite
  #
  # * Author: Sunil
  # * Date: 25/04/2019
  # * Reviewed By: Puneet
  #
  def invite
    service_response = TestEconomyManagement::Invite.new(params).perform
    return render_api_response(service_response)
  end

end
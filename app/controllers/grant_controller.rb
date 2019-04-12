class GrantController < AuthenticationController

  # Grant eth and ost
  #
  # * Author: Ankit
  # * Date: 18/01/2019
  # * Reviewed By: Sunil
  #
  def get
    service_response = TokenManagement::GrantEthOst.new(params).perform
    return render_api_response(service_response)
  end

end
class GrantController < AuthenticationController

  # Grant eth and stake currency.
  #
  # * Author: Ankit
  # * Date: 18/01/2019
  # * Reviewed By: Sunil
  #
  def get
    service_response = TokenManagement::GrantEthStakeCurrency.new(params).perform
    return render_api_response(service_response)
  end

end
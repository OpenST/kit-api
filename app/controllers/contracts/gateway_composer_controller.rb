class Contracts::GatewayComposerController < AuthenticationController

  # Get gateway composer
  #
  # * Author: Ankit
  # * Date: 19/01/2019
  # * Reviewed By: Sunil
  #
  def get_details
    service_response = ContractManagement::GetGatewayComposerAddress.new(params).perform
    render_api_response(service_response)
  end
end
class Token::AddressesController < AuthenticationController

  # Set token details
  #
  # * Author: Ankit
  # * Date: 19/01/2019
  # * Reviewed By: Sunil
  #
  def token_addresses_post
    service_response = WalletAddressesManagement::AssociateAddress.new(params).perform
    render_api_response(service_response)
  end
end
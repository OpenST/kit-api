class Token::AddressesController < AuthenticationController

  # Set token details
  #
  # * Author: Ankit
  # * Date: 19/01/2019
  # * Reviewed By: Sunil
  #
  def token_addresses_post
    service_response = WalletAddressesManagement::AssociateAddress.new(params).perform
    return render_api_response(service_response)
  end

  # Set token details
  #
  # * Author: Ankit
  # * Date: 23/04/2019
  # * Reviewed By:
  #
  def create_ost_managed_address
    service_response = WalletAddressesManagement::CreateOSTManagedAddress.new(params).perform
    return render_api_response(service_response)
  end
end
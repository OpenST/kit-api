class Token::AddressesController < WebController

  # Get Adresses
  #
  # * Author: Ankit
  # * Date: 19/12/2018
  # * Reviewed By:
  #
  def token_addresses_get
    service_response = WalletAddressesManagement::GetAddresses.new(params).perform
    render_api_response(service_response)
  end

  # Set token details
  #
  # * Author: Ankit
  # * Date: 19/12/2018
  # * Reviewed By:
  #
  def token_addresses_post
    service_response = WalletAddressesManagement::AssociateAddress.new(params).perform
    render_api_response(service_response)
  end

  # Set token details
  #
  # * Author: Ankit
  # * Date: 19/12/2018
  # * Reviewed By:
  #
  def token_addresses_is_available
    service_response = WalletAddressesManagement::IsAddressAvailable.new(params).perform
    render_api_response(service_response)
  end

  # Set token details
  #
  # * Author: Ankit
  # * Date: 19/12/2018
  # * Reviewed By:
  #
  def token_addresses_sign_messages
    service_response = WalletAddressesManagement::SignMessages.new().perform
    render_api_response(service_response)
  end
end
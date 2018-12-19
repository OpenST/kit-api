class TokenAddressesController < WebController

  # Get token details
  #
  # * Author: Ankit
  # * Date: 19/12/2018
  # * Reviewed By:
  #
  def token_addresses_get
    service_response = TokenManagement::GetTokenDetails.new(params).perform
    render_api_response(service_response)
  end

  # Set token details
  #
  # * Author: Ankit
  # * Date: 19/12/2018
  # * Reviewed By:
  #
  def token_addresses_post
    service_response = TokenManagement::InsertTokenDetails.new(params).perform
    render_api_response(service_response)
  end

  # Set token details
  #
  # * Author: Ankit
  # * Date: 19/12/2018
  # * Reviewed By:
  #
  def token_addresses_is_available
    service_response = TokenManagement::InsertTokenDetails.new(params).perform
    render_api_response(service_response)
  end
end
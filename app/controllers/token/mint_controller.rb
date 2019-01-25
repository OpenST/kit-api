class Token::MintController < WebController

  # token start mint
  #
  # * Author: Alpesh
  # * Date: 19/01/2019
  # * Reviewed By:
  #
  def mint_get
    service_response = TokenManagement::Mint.new(params).perform
    render_api_response(service_response)
  end

  # Start token minting
  #
  # * Author: Ankit
  # * Date: 18/01/2019
  # * Reviewed By:
  #
  def mint_post
    service_response = TokenManagement::StartMint.new(params).perform
    render_api_response(service_response)
  end

  # Grant eth and ost
  #
  # * Author: Ankit
  # * Date: 18/01/2019
  # * Reviewed By:
  #
  def grant_get
    service_response = TokenManagement::GrantEthOst.new(params).perform
    render_api_response(service_response)
  end


end

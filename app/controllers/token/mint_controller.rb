class Token::MintController < AuthenticationController

  # token start mint
  #
  # * Author: Alpesh
  # * Date: 19/01/2019
  # * Reviewed By: Sunil
  #
  def mint_get
    service_response = TokenManagement::Mint.new(params).perform
    return render_api_response(service_response)
  end

  # Start token minting
  #
  # * Author: Ankit
  # * Date: 18/01/2019
  # * Reviewed By: Sunil
  #
  def mint_post
    service_response = TokenManagement::StartMint.new(params).perform
    return render_api_response(service_response)
  end

  # Start token minting
  #
  # * Author: Anagha
  # * Date: 23/01/2019
  # * Reviewed By: Sunil
  #
  def mint_progress
    service_response = TokenManagement::MintProgress.new(params).perform
    return render_api_response(service_response)
  end
end

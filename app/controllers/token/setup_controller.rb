class Token::SetupController < WebController

  # Get token details
  #
  # * Author: Ankit
  # * Date: 19/01/2019
  # * Reviewed By:
  #
  def token_details_get
    service_response = TokenManagement::GetTokenDetails.new(params).perform
    render_api_response(service_response)
  end

  # Set token details
  #
  # * Author: Ankit
  # * Date: 19/01/2019
  # * Reviewed By:
  #
  def token_details_post
    service_response = TokenManagement::InsertTokenDetails.new(params).perform
    render_api_response(service_response)
  end

  # Start token deployment
  #
  # * Author: Ankit
  # * Date: 19/01/2019
  # * Reviewed By:
  #
  def deploy_post
    service_response = TokenManagement::StartDeployment.new(params).perform
    render_api_response(service_response)
  end

  # Start token deployment
  #
  # * Author: Shlok
  # * Date: 21/01/2018
  # * Reviewed By:
  #
  def deploy_get
    service_response = TokenManagement::GetDeploymentDetail.new(params).perform
    render_api_response(service_response)
  end

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

  # Start token minting
  #
  # * Author: Shlok
  # * Date: 22/01/2019
  # * Reviewed By:
  #
  def reset_deployment
    service_response = TokenManagement::ResetDeployment.new(params).perform
    render_api_response(service_response)
  end

  # Start token minting
  #
  # * Author: Anagha
  # * Date: 23/01/2019
  # * Reviewed By:
  #
  def mint_progress
    service_response = TokenManagement::MintProgress.new(params).perform
    render_api_response(service_response)
  end

end

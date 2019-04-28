class Token::PreMintController < AuthenticationController

  # Get pre mint details
  #
  # * Author: Ankit
  # * Date: 26/04/2019
  # * Reviewed By:
  #
  def get_pre_mint_details
    service_response = ::GetPreMintDetails.new(params).perform
    return render_api_response(service_response)
  end
end
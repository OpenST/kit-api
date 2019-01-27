module WalletAddressesManagement
  class SignMessages < ServicesBase

    # Initialize
    #
    # * Author: Ankit
    # * Date: 19/01/2019
    # * Reviewed By:
    #
    # @return [TokenManagement::SignMessages]
    #
    def initialize()

      super

      @api_response_data = {}

    end

    # Perform
    #
    # * Author: Ankit
    # * Date: 19/01/2019
    # * Reviewed By:
    #
    # @return [Result::Base]
    #
    def perform

      @api_response_data[:wallet_association] = GlobalConstant::MessageToSign.wallet_association

      success_with_data(@api_response_data)

    end
  end
end
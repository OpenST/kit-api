module SaasApi

  module Token

    class PreMintDetails < SaasApi::Base
      # Initialize
      #
      # * Author: Ankit
      # * Date: 26/04/2019
      # * Reviewed By:
      #
      # @return [SaasApi::Token::Mint]
      #
      def initialize
        super
      end

      # Perform
      #
      # * Author: Ankit
      # * Date: 26/04/2019
      # * Reviewed By:
      #
      # @return [Result::Base]
      #
      def perform(params = {})
        send_request_of_type(
          'get',
          GlobalConstant::SaasApi.pre_mint_details,
          params
        )
      end
    end

  end

end
module SaasApi

  module Token

    class StartMint < SaasApi::Base
      # Initialize
      #
      # * Author: Ankit
      # * Date: 15/01/2019
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
      # * Date: 15/01/2019
      # * Reviewed By:
      #
      # @return [Result::Base]
      #
      def perform(params = {})
        send_request_of_type(
          'post',
          GlobalConstant::SaasApi.start_mint,
          params
        )
      end
    end

  end

end
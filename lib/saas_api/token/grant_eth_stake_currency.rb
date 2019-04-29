module SaasApi

  module Token

    class GrantEthStakeCurrency < SaasApi::Base

      # Initialize
      #
      # * Author: Ankit
      # * Date: 24/01/2019
      # * Reviewed By:
      #
      # @return [SaasApi::Token::GrantEthStakeCurrency]
      #
      def initialize
        super
      end

      # Perform
      #
      # * Author: Ankit
      # * Date: 24/01/2019
      # * Reviewed By:
      #
      # @return [Result::Base]
      #
      def perform(params = {})
        send_request_of_type(
            'get',
            GlobalConstant::SaasApi.grant_eth_stake_currency,
            params
        )
      end

    end

  end

end

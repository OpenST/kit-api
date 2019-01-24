module SaasApi

  module Contract

    class GatewayComposer < SaasApi::Base
      # Initialize
      #
      # * Author: Ankit
      # * Date: 15/01/2019
      # * Reviewed By:
      #
      # @return [SaasApi::Token::Deploy]
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
          'get',
          GlobalConstant::SaasApi.get_gateway_composer,
          params
        )
      end
    end

  end

end
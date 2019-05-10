module SaasApi

  module Token

    class GetBalance < SaasApi::Base

      # Initialize
      #
      # * Author: Ankit
      # * Date: 29/04/2019
      # * Reviewed By:
      #
      # @return [SaasApi::Token::GetBalance]
      #
      def initialize
        super
      end

      # Perform
      #
      # * Author: Ankit
      # * Date: 29/04/2019
      # * Reviewed By:
      #
      # @return [Result::Base]
      #
      def perform(params = {})
        send_request_of_type(
          'get',
          GlobalConstant::SaasApi.get_balance,
          params
        )
      end

    end

  end

end

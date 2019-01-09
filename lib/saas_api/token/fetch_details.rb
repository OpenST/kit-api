module SaasApi

  module Token

    class FetchDetails < SaasApi::Base

      # Initialize
      #
      # * Author: Santhosh
      # * Date: 07/01/2019
      # * Reviewed By:
      #
      # @return [SaasApi::Token::FetchDetails]
      #
      def initialize
        super
      end

      # Perform
      #
      # * Author: Santhosh
      # * Date: 07/01/2019
      # * Reviewed By:
      #
      # @return [Result::Base]
      #
      def perform(params = {})
        send_request_of_type(
            'get',
            GlobalConstant::SaasApi.fetch_token_details,
            params
        )
      end

    end

  end

end

module SaasApi

  module Token

    class Deploy < SaasApi::Base
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
          GlobalConstant::SaasApi.token_deploy,
          params
        )
      end
    end

  end

end
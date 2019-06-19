module SaasApi

  module Client

    class RotateWebhookSecret < SaasApi::Base

      # Initialize
      #
      # * Author: Alpesh
      # * Date: 10/06/2018
      # * Reviewed By:
      #
      # @return [SaasApi::Client::RotateWebhookSecret]
      #
      def initialize
        super
      end

      # Perform
      #
      # * Author: Alpesh
      # * Date: 10/06/2018
      # * Reviewed By:
      #
      # @return [Result::Base]
      #
      def perform(params = {})
        send_request_of_type(
            'get',
            GlobalConstant::SaasApi.rotate_webhook_secret,
            params
        )
      end

    end

  end

end

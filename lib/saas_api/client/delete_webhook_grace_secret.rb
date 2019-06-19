module SaasApi

  module Client

    class DeleteWebhookGraceSecret < SaasApi::Base

      # Initialize
      #
      # * Author: Alpesh
      # * Date: 10/06/2018
      # * Reviewed By:
      #
      # @return [SaasApi::Client::DeleteWebhookGraceSecret]
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
            GlobalConstant::SaasApi.delete_webhook_grace_secret,
            params
        )
      end

    end

  end

end

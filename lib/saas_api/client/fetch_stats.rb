module SaasApi

  module Client

    class FetchStats < SaasApi::Base

      # Initialize
      #
      # * Author: Aman
      # * Date: 17/02/2018
      # * Reviewed By:
      #
      # @return [SaasApi::Transaction::FetchDetails]
      #
      def initialize
        super
      end

      # Perform
      #
      # * Author: Aman
      # * Date: 17/02/2018
      # * Reviewed By:
      #
      # @return [Result::Base]
      #
      def perform(params = {})
        send_request_of_type(
            'get',
            GlobalConstant::SaasApi.fetch_client_stats,
            params
        )
      end

    end

  end

end

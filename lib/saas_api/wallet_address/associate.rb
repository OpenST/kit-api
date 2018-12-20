module SaasApi

  module WalletAddress

    class Associate < SaasApi::Base

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
            'post',
            GlobalConstant::SaasApi.associate_address,
            params
        )
      end

    end

  end

end

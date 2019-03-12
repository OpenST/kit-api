module SaasApi

  module Dashboard

    class Get < SaasApi::Base

      # Initialize
      #
      # * Author: Alpesh
      # * Date: 06/03/2019
      # * Reviewed By:
      #
      # @return [SaasApi::Dashboard::Get]
      #
      def initialize
        super
      end

      # Perform
      #
      # * Author: Alpesh
      # * Date: 06/03/2019
      # * Reviewed By:
      #
      # @return [Result::Base]
      #
      def perform(params = {})
        send_request_of_type(
          'get',
          GlobalConstant::SaasApi.get_dashboard,
          params
        )
      end
    end

  end

end
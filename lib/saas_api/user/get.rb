module SaasApi

  module User

    class Get < SaasApi::Base

      # Initialize
      #
      # * Author: Santhosh
      # * Date: 08/05/2019
      # * Reviewed By:
      #
      # @return [SaasApi::User::Get]
      #
      def initialize
        super
      end

      # Perform
      #
      # * Author: Santhosh
      # * Date: 08/05/2019
      # * Reviewed By:
      #
      # @return [Result::Base]
      #
      def perform(params = {})
        send_request_of_type(
            'get',
            GlobalConstant::SaasApi.get_user_detail,
            params
        )
      end
    end

  end

end
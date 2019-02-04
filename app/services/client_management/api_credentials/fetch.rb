module ClientManagement

  module ApiCredentials

    class Fetch < ServicesBase

      # Initialize
      #
      # * Author: Puneet
      # * Date: 21/01/2019
      # * Reviewed By:
      #
      # @param [Integer] client_id (mandatory) - Client Id for which Api credentials has to be fetched
      #
      # @return [ClientManagement::ApiCredentials::Fetch]
      #
      def initialize(params)
        super
        @client_id = params[:client_id]
      end

      # Perform
      #
      # * Author: Puneet
      # * Date: 21/01/2019
      # * Reviewed By:
      #
      # @return [Result::Base]
      #
      def perform
        #temporary changes to unblock FE. 4Feb19
        fetch_token_details

        fetch_sub_env_payloads

        success_with_data({
                            token: @token,
                            sub_env_payloads: @sub_env_payload_data
                          }
          #api_credentials: KitSaasSharedCacheManagement::ApiCredentials.new([@client_id]).fetch[@client_id]
        )
      end

      # Fetch token details
      #
      #
      # * Author: Ankit
      # * Date: 19/01/2019
      # * Reviewed By:
      #
      # @return [Result::Base]
      def fetch_token_details
        @token = KitSaasSharedCacheManagement::TokenDetails.new([@client_id]).fetch[@client_id] || {}

        success
      end

      # fetch the sub env response data entity
      #
      # * Author: Ankit
      # * Date: 01/02/2019
      # * Reviewed By:
      #
      # @return [Result::Base]
      #
      def fetch_sub_env_payloads
        r = SubEnvPayload.new({client_id:@client_id}).perform
        return r unless r.success?

        @sub_env_payload_data = r.data[:sub_env_payloads]

        success
      end

    end

  end

end

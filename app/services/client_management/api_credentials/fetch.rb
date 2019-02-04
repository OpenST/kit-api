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
        success_with_data({}
          #api_credentials: KitSaasSharedCacheManagement::ApiCredentials.new([@client_id]).fetch[@client_id]
        )
      end

    end

  end

end

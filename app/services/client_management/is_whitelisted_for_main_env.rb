module ClientManagement

  class IsWhitelistedForMainEnv < ServicesBase

    # Initialize
    #
    # * Author: Puneet
    # * Date: 06/12/2018
    # * Reviewed By:
    #
    # @param [Integer] client_id (mandatory) -  client id
    #
    # @return [ClientManagement::IsWhitelistedForMainEnv]
    #
    def initialize(params)
      super
      @client_id = @params[:client_id]
    end

    # Perform
    #
    # * Author: Puneet
    # * Date: 21/01/2019
    # * Reviewed By:
    #
    def perform

      client_whitelisting = KitSaasSharedCacheManagement::ClientWhitelisting.new([@client_id]).fetch[@client_id]

      client_whitelisting.present? ? success : error_with_data(
                                                   'cm_iwfme_1',
                                                   'unauthorized_access_response',
                                                   GlobalConstant::ErrorAction.default
      )

    end

  end

end

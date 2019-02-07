module ClientManagement

  class IsWhitelistedForMainEnv < ServicesBase

    # Initialize
    #
    # * Author: Puneet
    # * Date: 06/12/2018
    # * Reviewed By:
    #
    # @params [Integer] client_id (mandatory) -  client id
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

      r = validate
      return r unless r.success?

      r = is_whitelisted_for_main
      return r unless r.success?

      success

    end

    # is client whitelisted to use main env
    #
    # * Author: Ankit
    # * Date: 06/02/2019
    # * Reviewed By:
    #
    def is_whitelisted_for_main
      client_whitelisting = KitSaasSharedCacheManagement::ClientWhitelisting.new([@client_id]).fetch[@client_id]

      client_whitelisting.present? ? success : error_with_data(
        'cm_iwfme_1',
        'unauthorized_access_response',
        GlobalConstant::ErrorAction.default
      )
    end

  end

end

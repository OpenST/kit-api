module DeveloperManagement
  class FetchDetails < ServicesBase

    # Initialize
    #
    # * Author: Ankit
    # * Date: 04/02/2019
    # * Reviewed By:
    #
    # @params [Integer] client_id (mandatory) - Client Id
    #
    # @return [DeveloperManagement::FetchDetails]
    #
    def initialize(params)

      super

      @api_response_data = {}

      @client_id = params[:client_id]
      @client_manager = params[:client_manager]

    end

    # Perform
    #
    # * Author: Ankit
    # * Date: 04/02/2019
    # * Reviewed By:
    #
    # @return [Result::Base]
    #
    def perform

      handle_errors_and_exceptions do

        validate

        r = fetch_token_details
        return r unless r.success?

        r = fetch_default_price_points
        return r unless r.success?

        r = fetch_sub_env_payloads
        return r unless r.success?

        @api_response_data = {
          token: @token,
          price_points: @price_points,
          client_manager: @client_manager,
          sub_env_payloads: @sub_env_payload_data
        }

        success_with_data(@api_response_data)

      end
    end

    # Fetch token details
    #
    #
    # * Author: Ankit
    # * Date: 04/02/2019
    # * Reviewed By:
    #
    # @return [Result::Base]
    def fetch_token_details
      @token = KitSaasSharedCacheManagement::TokenDetails.new([@client_id]).fetch[@client_id] || {}

      success
    end

    # Fetch default price points
    #
    #
    # * Author: Ankit
    # * Date: 04/02/2019
    # * Reviewed By:
    #
    # @return [Result::Base]
    def fetch_default_price_points
      @price_points = KitSaasSharedCacheManagement::OstPricePointsDefault.new.fetch

      success
    end

    # fetch the sub env response data entity
    #
    # * Author: Ankit
    # * Date: 04/02/2019
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
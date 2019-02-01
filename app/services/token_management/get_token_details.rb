module TokenManagement

  class GetTokenDetails < TokenManagement::Base

    # Initialize
    #
    # * Author: Ankit
    # * Date: 19/01/2019
    # * Reviewed By:
    #
    # @params [Integer] client_id (mandatory) - Client Id
    # @params [Object] client_manager(optional) - Client manager
    #
    # @return [TokenManagement::GetTokenDetails]
    #
    def initialize(params)

      super

      @client_manager = params[:client_manager]

      @api_response_data = {}

    end

    # Perform
    #
    # * Author: Ankit
    # * Date: 19/01/2019
    # * Reviewed By:
    #
    # @return [Result::Base]
    #
    def perform

      handle_errors_and_exceptions do

        validate

        fetch_token_details

        r = fetch_sub_env_payloads
        return r unless r.success?

        r = fetch_goto
        return r unless r.success?
        
        fetch_default_price_points

        @sign_message = {
          wallet_association: GlobalConstant::MessageToSign.wallet_association
        }

        success_with_data(
          {
            token: @token,
            sign_messages: @sign_message,
            client_manager: @client_manager,
            price_points: @price_points,
            sub_env_payloads: @sub_env_payload_data
          }
        )

      end

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

    # Fetch token details
    #
    # * Author: Shlok
    # * Date: 21/01/2019
    # * Reviewed By:
    #
    # @return [Result::Base]
    #
    def fetch_goto

      FetchGoToByEconomyState.new({
                                    token: @token,
                                    client_id: @client_id,
                                    from_page: GlobalConstant::GoTo.token_setup
                                  }).fetch_by_economy_state

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
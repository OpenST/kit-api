module TokenManagement

  class GetTokenDetailsBeforeSetup < TokenManagement::Base

    # Initialize
    #
    # * Author: Ankit
    # * Date: 19/01/2019
    # * Reviewed By:
    #
    # @params [Integer] client_id (mandatory) - Client Id
    # @params [Object] client_manager(optional) - Client manager
    # @params [Object] manager(mandatory) - manager
    #
    # @return [TokenManagement::GetTokenDetailsBeforeSetup]
    #
    def initialize(params)

      super

      @client_manager = @params[:client_manager]
      @manager = @params[:manager]

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

        r = validate
        return r unless r.success?

        r = fetch_token_details
        return r unless r.success?

        r = fetch_sub_env_payloads
        return r unless r.success?

        r = fetch_goto
        return r unless r.success?
        
        r = fetch_default_price_points
        return r unless r.success?

        @sign_message = {
          wallet_association: GlobalConstant::MessageToSign.wallet_association
        }

        api_response_data = {
            token: @token,
            sign_messages: @sign_message,
            client_manager: @client_manager,
            manager: @manager,
            price_points: @price_points,
            sub_env_payloads: @sub_env_payload_data
        }

        if @token[:stake_currency_id].present?
          api_response_data[:stake_currencies] = {@token[:stake_currency_id] => StakeCurrency.ids_to_details_cache[@token[:stake_currency_id]]}
        else
          api_response_data[:all_stake_currencies] = StakeCurrency.ids_to_details_cache.keys
        end

        success_with_data(api_response_data)

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

    # Fetch default price points. We have specifically added this method here because during token setup, a particular
    # chain is not allocated to a token. So we simply display the latest price point for any chain.
    #
    # * Author: Shlok
    # * Date: 05/03/2019
    # * Reviewed By:
    #
    # @return [Result::Base]
    def fetch_default_price_points
      @price_points = CacheManagement::OstPricePointsDefault.new.fetch

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
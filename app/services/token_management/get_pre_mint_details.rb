module TokenManagement

  class GetPreMintDetails < TokenManagement::Base

    # Initialize
    #
    # * Author: Ankit
    # * Date: 19/01/2019
    # * Reviewed By:
    #
    # @params [Integer] client_id (mandatory) - Client Id
    # @params [String] stake_currency_to_stake (mandatory) - in wei Stake Amount
    # @params [String] bt_to_mint (mandatory) - in wei Bt Amount
    #
    # @return [GetPreMintDetails]
    #
    def initialize(params)

      super

      @api_response_data = {}

      @stake_currency_to_stake_in_wei = params[:stake_currency_to_stake]
      @bt_to_mint_in_wei = params[:bt_to_mint]
      @client_id = @params[:client_id]

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

        r = validate_and_sanitize
        return r unless r.success?

        r = fetch_and_set_token_id
        return r unless r.success?

        r = direct_request_to_saas_api
        return r unless r.success?

        success_with_data(@api_response_data)

      end
    end

    private

    # Validate and sanitize
    #
    # * Author: Shlok
    # * Date: 14/09/2018
    # * Reviewed By:
    #
    # @return [Result::Base]
    #
    def validate_and_sanitize

      r = validate
      return r unless r.success?

      unless Util::CommonValidator.is_integer?(@client_id)
        return validation_error(
          'a_s_cm_ggca_1',
          'invalid_api_params',
          ['invalid_client_id'],
          GlobalConstant::ErrorAction.default
        )
      end

      @client_id = @client_id.to_i

      @stake_currency_to_stake_in_wei = @stake_currency_to_stake_in_wei.to_s
      @bt_to_mint_in_wei = @bt_to_mint_in_wei.to_s

      success

    end

    # Fetches token details and sets the token id in class variable
    #
    #
    # * Author: Ankit
    # * Date: 23/01/2019
    # * Reviewed By:
    #
    # @return [Result::Base]
    def fetch_and_set_token_id
      @token_details = KitSaasSharedCacheManagement::TokenDetails.new([@client_id]).fetch[@client_id]

      if @token_details.blank?
        return validation_error(
          'a_s_cm_ggca_3',
          'invalid_api_params',
          ['invalid_client_id'],
          GlobalConstant::ErrorAction.default
        )
      end

      @token_id = @token_details[:id]
      success
    end

    # Direct request to saas api
    #
    #
    # * Author: Ankit
    # * Date: 16/01/2019
    # * Reviewed By:
    #
    # @return [Result::Base]
    def direct_request_to_saas_api

      token_has_ost_managed_owner = @token_details[:properties].include?(GlobalConstant::ClientToken.has_ost_managed_owner)

      params_for_saas_api = {
        token_id: @token_id,
        client_id: @client_id,
        stake_currency_to_stake: @stake_currency_to_stake_in_wei,
        bt_to_mint: @bt_to_mint_in_wei,
        fetch_request_stake_tx_params: !token_has_ost_managed_owner
      }

      saas_response = SaasApi::Token::PreMintDetails.new.perform(params_for_saas_api)
      return saas_response unless saas_response.success?

      saas_response_data = saas_response.data

      unless token_has_ost_managed_owner
        @api_response_data[:contract_details] = {
            gateway_composer: {
                abi: GlobalConstant::ContractDetails::GatewayComposer.abi,
                address: saas_response_data['request_stake_tx_params']['gateway_composer_contract_address'],
                gas: GlobalConstant::ContractDetails::GatewayComposer.gas
            }
        }
        @api_response_data[:gas_price] = saas_response_data['request_stake_tx_params']['origin_chain_gas_price']
        @api_response_data[:request_stake_tx_params] = {
            gateway_contract: saas_response_data['request_stake_tx_params']['gateway_contract_address'],
            gas_price: saas_response_data['request_stake_tx_params']['gas_price'],
            gas_limit: saas_response_data['request_stake_tx_params']['gas_limit'],
            staker_gateway_nonce: saas_response_data['request_stake_tx_params']['staker_gateway_nonce'],
            stake_and_mint_beneficiary: saas_response_data['request_stake_tx_params']['stake_and_mint_beneficiary']
        }
      end

      @api_response_data[:precise_amounts] = saas_response_data['precise_amounts']

      success
    end
  end
end
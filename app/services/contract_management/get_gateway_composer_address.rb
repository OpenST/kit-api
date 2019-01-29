module ContractManagement
  class GetGatewayComposerAddress < ServicesBase

    # Initialize
    #
    # * Author: Ankit
    # * Date: 19/01/2019
    # * Reviewed By:
    #
    # @params [Integer] client_id (mandatory) - Client Id
    #
    # @return [TokenManagement::TokenDetails]
    #
    def initialize(params)

      super

      @api_response_data = {}

      @staker_address = params[:staker_address]
      @client_id = params[:client_id]


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

        validate_and_sanitize

        fetch_and_set_token_id

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

      validate

      unless Util::CommonValidator.is_ethereum_address?(@staker_address)
        fail OstCustomError.new validation_error(
                                  'a_s_cm_ggca_1',
                                  'invalid_api_params',
                                  ['invalid_staker_address'],
                                  GlobalConstant::ErrorAction.default
                                )
      end

      unless Util::CommonValidator.is_integer?(@client_id)
        return validation_error(
          'a_s_cm_ggca_2',
          'invalid_api_params',
          ['invalid_client_id'],
          GlobalConstant::ErrorAction.default
        )
      end

      @staker_address = Util::CommonValidator.sanitize_ethereum_address(@staker_address)

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
      params_for_saas_api = {
        token_id: @token_id,
        staker_address: @staker_address,
        client_id: @client_id
      }

      saas_response = SaasApi::Contract::GatewayComposer.new.perform(params_for_saas_api)
      return saas_response unless saas_response.success?

      saas_response_data = saas_response.data
      @api_response_data[:contract_details] = {
        gateway_composer: {
          abi: GlobalConstant::ContractDetails::GatewayComposer.abi,
          address: saas_response_data['gateway_composer_contract_address'],
          gas: GlobalConstant::ContractDetails::GatewayComposer.gas
        }
      }
      @api_response_data[:gas_price] = saas_response_data['origin_chain_gas_price']
      @api_response_data[:request_stake_tx_params] = {
        gateway_contract: saas_response_data['gateway_contract_address'],
        gas_price: '0',
        gas_limit: '0',
        staker_gateway_nonce: saas_response_data['staker_gateway_nonce'],
        stake_and_mint_beneficiary: saas_response_data['stake_and_mint_beneficiary']
      }

      success
    end

  end
end
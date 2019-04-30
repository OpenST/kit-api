module TokenManagement

  class Mint < TokenManagement::Base

    # Initialize
    #
    # * Author: Alpesh
    # * Date: 18/01/2018
    # * Reviewed By:
    #
    # @params [Integer] client_id (mandatory) - Client Id
    # @params [Object] manager(mandatory) - manager
    # @params [Hash] client_manager (optional) - Client manager hash
    #
    # @return [TokenManagement::Mint]
    #
    def initialize(params)

      super

      @client_manager = @params[:client_manager]
      @manager = @params[:manager]

      @api_response_data = {}
      @mint_workflow = nil

    end

    # Perform
    #
    # * Author: Alpesh
    # * Date: 18/01/2018
    # * Reviewed By:
    #
    # @return [Result::Base]
    #
    def perform

      handle_errors_and_exceptions do

        r = validate_and_sanitize
        return r unless r.success?

        r = fetch_workflows
        return r unless r.success?

        r = fetch_token
        return r unless r.success?

        r = fetch_goto
        return r unless r.success?

        r = add_token_to_response
        return r unless r.success?

        r = fetch_addresses
        return r unless r.success?

        r = get_details_from_saas
        return r unless r.success?

        r = fetch_price_points
        return r unless r.success?

        r = append_logged_in_manager_details
        return r unless r.success?

        r = fetch_sub_env_payloads
        return r unless r.success?

        return success_with_data(@api_response_data)
      end

    end

    # Validate and sanitize
    #
    # * Author: Alpesh
    # * Date: 18/01/2018
    # * Reviewed By:
    #
    # @return [Result::Base]
    #
    def validate_and_sanitize
      r = validate
      return r unless r.success?

      success
    end

    # Fetch workflow
    #
    # * Author: Alpesh
    # * Date: 18/01/2018
    # * Reviewed By:
    #
    # @return [Result::Base]
    #
    def fetch_workflows
      workflows = CacheManagement::WorkflowByClient.new([@client_id]).fetch
      @api_response_data[:workflow] = {}

      if workflows.present? && workflows[@client_id].present?
        workflows[@client_id].each do |wf|
          if wf.kind == GlobalConstant::Workflow.grant_eth_stake_currency && wf.status == GlobalConstant::Workflow.in_progress
            @api_response_data[:workflow] = {id: wf.id, kind: wf.kind}
          elsif wf.kind == GlobalConstant::Workflow.bt_stake_and_mint
            @mint_workflow ||= wf
          end
        end
      end

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
                                    mint_workflow: @mint_workflow,
                                    from_page: GlobalConstant::GoTo.token_mint
                                  }).fetch_by_economy_state

    end

    # Fetch addresses details
    #
    # * Author: Alpesh
    # * Date: 18/01/2018
    # * Reviewed By:
    #
    # @return [Result::Base]
    #
    def fetch_addresses
      token_id = @token[:id]
      addresses_data = KitSaasSharedCacheManagement::TokenAddresses.new([token_id]).fetch

      origin_addresses = {}
      owner_address = [addresses_data[token_id][GlobalConstant::TokenAddresses.owner_address_kind][:address]]

      origin_addresses[:whitelisted] = owner_address
      origin_addresses[:workers] = addresses_data[token_id][GlobalConstant::TokenAddresses.origin_worker_address_kind][:address] ||= []
      origin_addresses[:owner] = addresses_data[token_id][GlobalConstant::TokenAddresses.owner_address_kind][:address]
      origin_addresses[:admin] = addresses_data[token_id][GlobalConstant::TokenAddresses.origin_admin_address_kind][:address]


      aux_addresses = {}
      aux_addresses[:whitelisted] = owner_address
      aux_addresses[:workers] = addresses_data[token_id][GlobalConstant::TokenAddresses.aux_worker_address_kind][:address] ||= []
      aux_addresses[:owner] = addresses_data[token_id][GlobalConstant::TokenAddresses.owner_address_kind][:address]
      aux_addresses[:admin] = addresses_data[token_id][GlobalConstant::TokenAddresses.aux_admin_address_kind][:address]

      @api_response_data[:origin_addresses] = origin_addresses
      @api_response_data[:auxiliary_addresses] = aux_addresses

      success
    end

    # Get necessary details from saas.
    #
    # * Author: Alpesh
    # * Date: 18/01/2018
    # * Reviewed By:
    #
    # @return [Result::Base]
    # @sets @api_response_data[:contract_details], @api_response_data[:gas_price]
    #
    def get_details_from_saas
      total_gas_for_mint = GlobalConstant::ContractDetails::StakeCurrency.gas[:approve].to_i(16) + GlobalConstant::ContractDetails::GatewayComposer.gas[:requestStake].to_i(16)
      params = {
        client_id: @client_id,
        total_gas_for_mint: total_gas_for_mint
      }
      saas_response = SaasApi::Token::MintDetails.new.perform(params)
      return saas_response unless saas_response.success?

      #Todo: Check if we need to send simple_token abi/gas when owner is ost managed

      @api_response_data[:contract_details] = {
        simple_token: { # TODO:@Shlok Replace 'simple_token' -> 'stake_currency'
          abi: GlobalConstant::ContractDetails::StakeCurrency.abi,
          gas: GlobalConstant::ContractDetails::StakeCurrency.gas,
          address: saas_response.data["contract_address"]["stake_currency"]
        },
        branded_token: {
          abi: GlobalConstant::ContractDetails::BrandedToken.abi,
          gas: GlobalConstant::ContractDetails::BrandedToken.gas,
          address: saas_response.data["contract_address"]["branded_token"]
        }
      }


      @api_response_data[:min_ost_in_wei] = saas_response.data["minimum_stake_currency_required"]
      # TODO:@Shlok Replace 'min_ost_in_wei' -> 'minimum_stake_currency_in_wei'
      @api_response_data[:min_eth_in_wei] = saas_response.data["minimum_eth_required"]

      @api_response_data[:gas_price] = saas_response.data["gas_price"]

      success
    end

    # Append logged in manager details
    #
    # * Author: Alpesh
    # * Date: 18/01/2018
    # * Reviewed By:
    #
    # @return [Result::Base]
    #
    def append_logged_in_manager_details
      return success unless @client_manager.present?

      @api_response_data[:client_manager] = @client_manager
      @api_response_data[:manager] = @manager

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

      @api_response_data['sub_env_payloads'] = r.data[:sub_env_payloads]

      success
    end

  end

end

module TokenManagement

  class Mint < TokenManagement::Base

    # Initialize
    #
    # * Author: Alpesh
    # * Date: 18/01/2018
    # * Reviewed By:
    #
    # @params [Integer] client_id (mandatory) - Client Id
    # @params [Hash] client_manager (optional) - Client manager hash
    #
    # @return [TokenManagement::Mint]
    #
    def initialize(params)

      super

      @client_manager = params[:client_manager]

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

        validate_and_sanitize

        fetch_workflows

        fetch_and_validate_token

        r = fetch_goto
        return r unless r.success?

        add_token_to_response

        fetch_addresses

        get_details_from_saas

        fetch_default_price_points

        append_logged_in_manager_details

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
      validate
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
          if wf.kind == GlobalConstant::Workflow.grant_eth_ost && wf.status == GlobalConstant::Workflow.in_progress
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
      ownerAddress = [addresses_data[token_id][GlobalConstant::TokenAddresses.owner_address_kind]]

      origin_addresses[:whitelisted] = ownerAddress
      origin_addresses[:workers] = addresses_data[token_id][GlobalConstant::TokenAddresses.origin_worker_address_kind] ||= []
      origin_addresses[:owner] = addresses_data[token_id][GlobalConstant::TokenAddresses.owner_address_kind]
      origin_addresses[:admin] = addresses_data[token_id][GlobalConstant::TokenAddresses.origin_admin_address_kind]


      aux_addresses = {}
      aux_addresses[:whitelisted] = ownerAddress
      aux_addresses[:workers] = addresses_data[token_id][GlobalConstant::TokenAddresses.aux_worker_address_kind] ||= []
      aux_addresses[:owner] = addresses_data[token_id][GlobalConstant::TokenAddresses.owner_address_kind]
      aux_addresses[:admin] = addresses_data[token_id][GlobalConstant::TokenAddresses.aux_admin_address_kind]

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
      total_gas_for_mint = GlobalConstant::ContractDetails::SimpleToken.gas[:approve].to_i(16) + GlobalConstant::ContractDetails::GatewayComposer.gas[:requestStake].to_i(16)
      params = {
        client_id: @client_id,
        total_gas_for_mint: total_gas_for_mint
      }
      saas_response = SaasApi::Token::MintDetails.new.perform(params)
      return saas_response unless saas_response.success?

      @api_response_data[:contract_details] = {
        simple_token: {
          abi: GlobalConstant::ContractDetails::SimpleToken.abi,
          gas: GlobalConstant::ContractDetails::SimpleToken.gas,
          address: saas_response.data["contract_address"]["simple_token"]
        },
        branded_token: {
          abi: GlobalConstant::ContractDetails::BrandedToken.abi,
          gas: GlobalConstant::ContractDetails::BrandedToken.gas,
          address: saas_response.data["contract_address"]["branded_token"]
        }
      }


      @api_response_data[:min_ost_in_wei] = saas_response.data["minimum_ost_required"]
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

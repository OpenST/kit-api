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
    # @return [TokenManagement::TokenDetails]
    #
    def initialize(params)

      super

      @client_manager = params[:client_manager]

      @api_response_data = {}

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
      @api_response_data[:workflow] = []

      if workflows.present? && workflows[@client_id].present?
        workflows[@client_id].each do |wf|
          if wf.status == GlobalConstant::Workflow.grant_eth_ost
            @api_response_data[:workflow].push({id: wf.id, kind: wf.kind})
          elsif wf.status == GlobalConstant::Workflow.token_deploy
            @deployment_workflow ||= wf
          elsif wf.status == GlobalConstant::Workflow.stake_and_mint
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
                                    deployment_workflow: @deployment_workflow,
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
      addresses_data = CacheManagement::TokenAddresses.new([token_id]).fetch
      addresses = {}
      addresses[:whitelisted] = addresses_data[token_id][GlobalConstant::TokenAddresses.owner_address_kind] ||= []
      addresses[:workers] = addresses_data[token_id][GlobalConstant::TokenAddresses.worker_address_kind] ||= []
      addresses[:owner] = addresses_data[token_id][GlobalConstant::TokenAddresses.owner_address_kind]
      addresses[:admin] = addresses_data[token_id][GlobalConstant::TokenAddresses.admin_address_kind]

      @api_response_data[:origin_addresses] = addresses
      @api_response_data[:auxiliary_addresses] = addresses

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
      params = {
        client_id: @client_id
      }
      saas_response = SaasApi::Token::MintDetails.new.perform(params)
      return saas_response unless saas_response.success?

      @api_response_data[:contract_details] = {
        simple_token: {
          abi: GlobalConstant::ContractDetails::SimpleToken.abi,
          gas: GlobalConstant::ContractDetails::SimpleToken.gas,
          address: saas_response.data["contract_address"]["simple_token"]["address"]
        }
      }

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

  end

end

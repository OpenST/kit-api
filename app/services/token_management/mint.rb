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
      @token_id = nil
      @workflows = {}

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

        fetch_running_workflows

        fetch_and_validate_token

        add_token_to_response

        @token_id = @token[:id]

        fetch_addresses

        get_details_from_saas

        fetch_default_price_points

        append_logged_in_manager_details

        fetch_origin_gas_price

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

    # Fetch workflows that are running. If token setup is running redirect.
    #
    # * Author: Alpesh
    # * Date: 18/01/2018
    # * Reviewed By:
    #
    # @return [Result::Base]
    #
    def fetch_running_workflows
      workflows = CacheManagement::WorkflowByClient.new([@client_id]).fetch
      @api_response_data[:workflows] = []

      if workflows.present? && workflows[@client_id].present?
        workflows[@client_id].each do |wf|
          if wf.kind == GlobalConstant::Workflow.token_deploy
            return error_with_go_to('s_tm_m_1', 'invalid_api_params', GlobalConstant::GoTo.token_deploy)
          end
          @api_response_data[:workflows].push(
            {
              id: wf.id,
              kind: wf.kind
            }) if wf.status == GlobalConstant::Workflow.in_progress
        end
      end

      success
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
      addresses_data = CacheManagement::TokenAddresses.new([@token_id]).fetch
      addresses = {}
      addresses[:whitelisted] = addresses_data[@token_id][GlobalConstant::TokenAddresses.owner_address_kind] ||= []
      addresses[:workers] = addresses_data[@token_id][GlobalConstant::TokenAddresses.worker_address_kind] ||= []
      addresses[:owner] = addresses_data[@token_id][GlobalConstant::TokenAddresses.owner_address_kind]
      addresses[:admin] = addresses_data[@token_id][GlobalConstant::TokenAddresses.admin_address_kind]

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
    #
    def get_details_from_saas
      @api_response_data[:contract_details] = {
        simple_token: {
          abi: GlobalConstant::ContractDetails::SimpleToken.abi,
          gas: GlobalConstant::ContractDetails::SimpleToken.gas,
          address: "0xkdldj3o0eifo3idm......"
        }
      }

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

    # Fetch dynamic gas price.
    #
    # * Author: Alpesh
    # * Date: 18/01/2018
    # * Reviewed By:
    #
    # @return [Result::Base]
    #
    def fetch_origin_gas_price
      @api_response_data[:gas_price] = {origin: 0}

      success
    end

  end

end

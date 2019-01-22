module TokenManagement

  class StartDeployment < TokenManagement::Base

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
      @token_id = nil
      @workflow_id = nil

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

        fetch_and_validate_token

        add_token_to_response

        @token_id = @token[:id]

        direct_request_to_saas_api

        fetch_workflow_current_status

        success_with_data(@api_response_data)

      end
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
        client_id: @client_id
      }

      saas_response = SaasApi::Token::Deploy.new.perform(params_for_saas_api)
      return saas_response unless saas_response.success?

      @workflow_id = saas_response.data['workflow_id']

      success
    end


    # Fetch workflow current status
    #
    #
    # * Author: Ankit
    # * Date: 16/01/2019
    # * Reviewed By:
    #
    # @return [Result::Base]
    def fetch_workflow_current_status

      cached_response_data = CacheManagement::WorkflowStatus.new([@workflow_id]).fetch

      fail OstCustomError.new validation_error(
                                'tm_sd_1',
                                'invalid_api_params',
                                ['invalid_workflow_id'],
                                GlobalConstant::ErrorAction.default
                              ) if cached_response_data[@workflow_id].blank?

      @api_response_data['workflow_current_step'] = cached_response_data[@workflow_id][:current_step]

      @api_response_data['workflow'] = {
        id: @workflow_id,
        kind: GlobalConstant::Workflow.token_deploy
      }

      success
    end


  end

end
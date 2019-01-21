module TokenManagement

  class Deploy < ServicesBase

    # Initialize
    #
    # * Author: Ankit
    # * Date: 19/12/2018
    # * Reviewed By:
    #
    # @params [Integer] client_id (mandatory) - Client Id
    #
    # @return [TokenManagement::TokenDetails]
    #
    def initialize(params)

      super

      @client_id = params[:client_id]

      @api_response_data = {}
      @token_id = nil
      @workflow_id = nil

    end

    # Perform
    #
    # * Author: Ankit
    # * Date: 19/12/2018
    # * Reviewed By:
    #
    # @return [Result::Base]
    #
    def perform

      handle_errors_and_exceptions do

        r = validate_and_sanitize
        return r unless r.success?

        Rails.logger.info("----------------@client_id-----#{@client_id}")
        r = fetch_token_details
        return r unless r.success?

        r = direct_request_to_saas_api
        return r unless r.success?

        r = fetch_workflow_current_status
        return r unless r.success?

        success_with_data(@api_response_data)

        # return success_with_data({
        #   token: {
        #     "name": "Pepo Coin",
        #     "symbol": "Pepo",
        #     "conversion_factor": "2.5",
        #     "status": ""
        #   },
        #   workflow: {
        #     "id": "123...",
        #     "kind": "token_deploy"
        #   },
        #   workflow_current_step: {
        #     "display_text": "",
        #     "percent_completion": 10,
        #     "status": 0,
        #     "name": "step_name"
        #   }
        # })

      end
    end

    def validate_and_sanitize
      validate
    end

    # Fetch token details
    #
    # * Author: Ankit
    # * Date: 17/01/2019
    # * Reviewed By:
    #
    # @return [Result::Base]
    #
    def fetch_token_details
      r = CacheManagement::TokenDetails.new([@client_id]).fetch || {}
      #Todo add check if no data is returned from cache return error
      @api_response_data[:token] = r[@client_id]
      @token_id = r[@client_id][:id]
      success
    end

    # direct request to saas api
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

      r = SaasApi::Token::Deploy.new.perform(params_for_saas_api)
      return r unless r.success?

      @workflow_id = r.data['workflow_id']

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
      @api_response_data['workflow_current_step'] = cached_response_data[@workflow_id][:current_step]

      @api_response_data['workflow'] = {
        id: @workflow_id,
        kind: GlobalConstant::Workflow.token_deploy
      }

      success
    end


  end

end
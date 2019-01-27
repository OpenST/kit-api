module TokenManagement

  class GetDeploymentDetail < TokenManagement::Base

    # Initialize
    #
    # * Author: Shlok
    # * Date: 21/01/2019
    # * Reviewed By:
    #
    # @params [Integer] client_id (mandatory) - Client Id
    #
    # @return [TokenManagement::GetDeploymentDetail]
    #
    def initialize(params)

      super

      @api_response_data = {}
      @token_id = nil
      @workflow_id = nil

    end

    # Perform
    #
    # * Author: Shlok
    # * Date: 21/01/2019
    # * Reviewed By:
    #
    # @return [Result::Base]
    #
    def perform

      handle_errors_and_exceptions do

        validate

        fetch_and_validate_token

        add_token_to_response

        fetch_workflow

        r = fetch_goto
        return r unless r.success?

        fetch_workflow_current_status

        success_with_data(@api_response_data)

      end
    end

    # Fetch workflow details
    #
    # * Author: Shlok
    # * Date: 21/01/2019
    # * Reviewed By:
    #
    # @return [Result::Base]
    #
    def fetch_workflow
      @deployment_workflow = Workflow.where({
                                   client_id: @client_id,
                                   kind: Workflow.kinds[GlobalConstant::Workflow.token_deploy]
                                 })
                    .order('id DESC')
                    .limit(1).first
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
                                    from_page: GlobalConstant::GoTo.token_deploy
                                  }).fetch_by_economy_state

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

      cached_response_data = KitSaasSharedCacheManagement::WorkflowStatus.new([@deployment_workflow.id]).fetch

      @api_response_data['workflow_current_step'] = {}

      if cached_response_data[@deployment_workflow.id].present?
        @api_response_data['workflow_current_step'] = cached_response_data[@deployment_workflow.id][:current_step]
      end

      @api_response_data['workflow'] = {
        id: @deployment_workflow.id,
        kind: GlobalConstant::Workflow.token_deploy
      }

      success
    end


  end

end
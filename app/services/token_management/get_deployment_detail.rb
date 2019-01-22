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

        fetch_goto

        fetch_workflow

        success_with_data(@api_response_data)

      end
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

      client = Util::EntityHelper.fetch_and_validate_client(@client_id, 'tm_gdd')
      client_id = client[:id]
      token = CacheManagement::TokenDetails.new([client_id]).fetch[client_id]

      goto = FetchGoToByEconomyState.new({
                                    token: token,
                                    client: client,
                                  }).fetch_by_economy_state

      @api_response_data[go_to: goto]

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
      @workflow = Workflow.where({
                                          client_id: @client_id,
                                          kind: Workflow.kinds[GlobalConstant::Workflow.token_deploy]
                                        })
                           .order('id DESC')
                            .limit(1).first
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

      cached_response_data = CacheManagement::WorkflowStatus.new([@workflow.id]).fetch

      fail OstCustomError.new validation_error(
                                'tm_sd_1',
                                'invalid_api_params',
                                ['invalid_workflow_id'],
                                GlobalConstant::ErrorAction.default
                              ) if cached_response_data[@workflow.id].blank?

      @api_response_data['workflow_current_step'] = cached_response_data[@workflow.id][:current_step]

      @api_response_data['workflow'] = {
        id: @workflow.id,
        kind: GlobalConstant::Workflow.token_deploy
      }

      success
    end


  end

end
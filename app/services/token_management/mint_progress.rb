module TokenManagement
  class MintProgress < TokenManagement:: Base

    # Initialize
    #
    # * Author: Anagha
    # * Date: 23/01/2019
    # * Reviewed By:
    #
    # @params [Integer] client_id (mandatory) - Client Id
    #
    #
    def initialize(params)
      super
      @client_manager = params[:client_manager]
      @api_response_data = {}
      @mint_workflow = nil
    end


    # Perform
    #
    # * Author: Anagha
    # * Date: 23/01/2019
    # * Reviewed By:
    #
    # @return [Result::Base]
    #
    def perform

      handle_errors_and_exceptions do

        r = validate_and_sanitize
        return r unless r.success?

        r = fetch_and_validate_token
        return r unless r.success?

        r = fetch_workflows
        return r unless r.success?

        r = fetch_goto
        return r unless r.success?

        r = add_token_to_response
        return r unless r.success?

        @token_id = @token[:id]

        r = fetch_workflow_current_status
        return r unless r.success?

        r = fetch_default_price_points
        return r unless r.success?

        r = append_logged_in_manager_details
        return r unless r.success?

        r = fetch_sub_env_payloads
        return r unless r.success?

        success_with_data(@api_response_data)

      end
    end

    # Validate and sanitize
    #
    # * Author: Anagha
    # * Date: 24/01/2018
    # * Reviewed By:
    #
    # @return [Result::Base]
    #
    def validate_and_sanitize
      r = validate
      return r unless r.success?

      unless Util::CommonValidator.is_integer?(@client_id)
        return validation_error(
          'a_s_tm_mp_1',
          'invalid_api_params',
          ['invalid_client_id'],
          GlobalConstant::ErrorAction.default
        )
      end

      success
    end

    # Fetch workflow details
    #
    # * Author: Shlok
    # * Date: 21/01/2019
    # * Reviewed By:
    #
    # @return [Result::Base]
    #
    def fetch_workflows

      workflows = CacheManagement::WorkflowByClient.new([@client_id]).fetch
      @api_response_data[:workflow] = {}

      if(workflows.present? && workflows[@client_id].present?)
        workflows[@client_id].each do |wf|
          if wf.kind == GlobalConstant::Workflow.bt_stake_and_mint
            if wf.status == GlobalConstant::Workflow.in_progress || wf.status == GlobalConstant::Workflow.failed
              @api_response_data[:workflow] = {id: wf.id, kind: wf.kind}
              @workflow_id = wf.id
            end
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
                                    from_page: GlobalConstant::GoTo.token_mint_progress
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

      cached_response_data = KitSaasSharedCacheManagement::WorkflowStatus.new([@workflow_id]).fetch

      workflow_current_step = {}
      if cached_response_data[@workflow_id].present?
        workflow_current_step = cached_response_data[@workflow_id][:current_step]
      end
      @api_response_data['workflow_current_step'] = workflow_current_step

      cached_workflow_data = KitSaasSharedCacheManagement::Workflow.new([@workflow_id]).fetch

      @api_response_data['workflow_payload'] = Oj.load(cached_workflow_data[@workflow_id][:response_data], {})

      success
    end


    # Fetch default price points
    #
    #
    # * Author: Anagha
    # * Date: 23/01/2019
    # * Reviewed By:
    #
    # @return [Result::Base]
    def fetch_default_price_points
      @api_response_data[:price_points] = KitSaasSharedCacheManagement::OstPricePointsDefault.new.fetch
      success
    end

    # Append logged in manager details
    #
    # * Author: Anagha
    # * Date: 23/01/2018
    # * Reviewed By:
    #
    # @return [Result::Base]
    #
    def append_logged_in_manager_details
      return success unless @client_manager.present?

      if @client_manager.present?
        @api_response_data[:client_manager] = @client_manager
      end

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


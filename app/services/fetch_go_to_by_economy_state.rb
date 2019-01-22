class FetchGoToByEconomyState < ServicesBase

  # Initialize
  #
  # * Author: Puneet
  # * Date: 06/12/2018
  # * Reviewed By:
  #
  # @param [Hash] params (mandatory)
  #
  # @return [GoTo::ByManagerState]
  #
  def initialize(params)

    super

    @token = params[:token]
    @client_id = params[:client_id]
    @workflow = params[:workflow]
    @from_page = params[:from_page]
  end

  # Perform
  #
  # * Author: Puneet
  # * Date: 06/12/2018
  # * Reviewed By:
  #
  # @return [Hash]
  #
  def fetch_by_economy_state
    handle_errors_and_exceptions do

      go_to = {}

      return error_with_go_to('s_fgtbes_1', 'data_validation_failed', GlobalConstant::GoTo.token_setup) if @token.blank? ||
        @workflow.blank? ||
        @token[:status] == GlobalConstant::ClientToken.not_deployed

      # If token deployment has started.
      if @token[:status] == GlobalConstant::ClientToken.deployment_started

        fail OstCustomError.new validation_error(
                                  's_fgt_3',
                                  'invalid_token_deployment_workflow_status',
                                  [],
                                  GlobalConstant::ErrorAction.default
                                ) unless @workflow.status == GlobalConstant::Workflow.in_progress

        go_to = GlobalConstant::GoTo.token_deploy

      elsif @token[:status] == GlobalConstant::ClientToken.deployment_completed

        fail OstCustomError.new validation_error(
                                  's_fgt_4',
                                  'invalid_token_deployment_workflow_status',
                                  [],
                                  GlobalConstant::ErrorAction.default
                                ) unless @workflow.status == GlobalConstant::Workflow.completed

        go_to = GlobalConstant::GoTo.token_mint

      elsif @token[:status] == GlobalConstant::ClientToken.deployment_failed

        fail OstCustomError.new validation_error(
                                  's_fgt_5',
                                  'invalid_token_deployment_workflow_status',
                                  [],
                                  GlobalConstant::ErrorAction.default
                                ) unless @workflow.status == GlobalConstant::Workflow.failed

        go_to = GlobalConstant::GoTo.service_unavailable

      end

      if go_to.blank? || go_to[:by_screen_name] == @from_page[:by_screen_name]
        return success
      else
        return error_with_go_to('s_fgtbes_2', 'data_validation_failed', go_to)
      end

    end
  end

end
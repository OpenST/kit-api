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
    #TODO: Get this verified.
    handle_errors_and_exceptions do

      return GlobalConstant::GoTo.token_setup if @token.status == GlobalConstant::ClientToken.not_deployed

      # Fetch workflow details.
      workflow_details = Workflow.where({
                                         client_id: @client_id,
                                         kind: Workflow.kind[GlobalConstant::Workflow.token_deploy]
                                       }).first

      fail OstCustomError.new validation_error(
                                's_fgt_2',
                                'workflow_empty',
                                [],
                                GlobalConstant::ErrorAction.default
                              ) if workflow_details.blank?

      # If token deployment has started.
      if @token.status == GlobalConstant::ClientToken.deployment_started

        fail OstCustomError.new validation_error(
                                  's_fgt_3',
                                  'invalid_token_deployment_workflow_status',
                                  [],
                                  GlobalConstant::ErrorAction.default
                                ) unless workflow_details.status == GlobalConstant::Workflow.in_progress

        return GlobalConstant::GoTo.token_deploy

      end

      # If token deployment has completed.
      if @token.status == GlobalConstant::ClientToken.deployment_completed

        fail OstCustomError.new validation_error(
                                  's_fgt_4',
                                  'invalid_token_deployment_workflow_status',
                                  [],
                                  GlobalConstant::ErrorAction.default
                                ) unless workflow_details.status == GlobalConstant::Workflow.completed

        return GlobalConstant::GoTo.token_mint

      end

      # If token deployment has failed.
      if @token.status == GlobalConstant::ClientToken.deployment_failed

        fail OstCustomError.new validation_error(
                                  's_fgt_5',
                                  'invalid_token_deployment_workflow_status',
                                  [],
                                  GlobalConstant::ErrorAction.default
                                ) unless workflow_details.status == GlobalConstant::Workflow.failed

        return GlobalConstant::GoTo.service_unavailable

      end
    end
  end

end
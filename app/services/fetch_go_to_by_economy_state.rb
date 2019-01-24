class FetchGoToByEconomyState < ServicesBase

  # Initialize
  #
  # * Author: Shlok
  # * Date: 23/01/2019
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
    @deployment_workflow = params[:deployment_workflow]
    @from_page = params[:from_page]
    @mint_workflow = params[:mint_workflow]

  end

  # Fetch by economy state
  #
  # * Author: Shlok
  # * Date: 23/01/2019
  # * Reviewed By:
  #
  # @return [Hash]
  #
  def fetch_by_economy_state

    handle_errors_and_exceptions do

      go_to = {}

      # Return token_setup if token doesn't exist or it is not deployed yet.
      if @token.blank? || @deployment_workflow.blank? || @token[:status] == GlobalConstant::ClientToken.not_deployed

        go_to = GlobalConstant::GoTo.token_setup

        # If mint workflow is present.
      elsif @mint_workflow.present?

        # If mint workflow is present, token status should be deployed and deployment_workflow should be completed.
        if @token[:status] == GlobalConstant::ClientToken.deployment_completed &&
          @deployment_workflow.status == GlobalConstant::Workflow.completed

          # If mint workflow is in progress, redirect to token mint page.
          if @mint_workflow.status === GlobalConstant::Workflow.in_progress
            go_to = GlobalConstant::GoTo.token_mint
          else
            go_to = 'something'  # TODO: Add here.
          end

        # Token deployment was not completed yet. So redirect to token deployment pages.
        else
          go_to = fetch_deployment_goto
        end
      # Mint workflow is not present. That means token deployment has not completed yet. So redirect to token deployment pages.
      else
        go_to = fetch_deployment_goto
      end

      # If go_to is blank or is same as the from_page, do not redirect.
      if go_to.blank? || go_to[:by_screen_name] == @from_page[:by_screen_name]
        return success
      else
        return error_with_go_to('s_fgtbes_2', 'data_validation_failed', go_to)
      end

    end

  end

  # Fetch go_to for token deployment state
  #
  # * Author: Shlok
  # * Date: 24/01/2019
  # * Reviewed By:
  #
  # @return [Hash]
  #
  def fetch_deployment_goto

    if @token[:status] == GlobalConstant::ClientToken.deployment_started

      fail OstCustomError.new validation_error(
                                's_fgt_3',
                                'invalid_token_deployment_workflow_status',
                                [],
                                GlobalConstant::ErrorAction.default
                              ) unless @deployment_workflow.status == GlobalConstant::Workflow.in_progress

      GlobalConstant::GoTo.token_deploy

    elsif @token[:status] == GlobalConstant::ClientToken.deployment_completed

      fail OstCustomError.new validation_error(
                                's_fgt_4',
                                'invalid_token_deployment_workflow_status',
                                [],
                                GlobalConstant::ErrorAction.default
                              ) unless @deployment_workflow.status == GlobalConstant::Workflow.completed

      GlobalConstant::GoTo.token_mint

    elsif @token[:status] == GlobalConstant::ClientToken.deployment_failed

      fail OstCustomError.new validation_error(
                                's_fgt_5',
                                'invalid_token_deployment_workflow_status',
                                [],
                                GlobalConstant::ErrorAction.default
                              ) unless @deployment_workflow.status == GlobalConstant::Workflow.failed

      GlobalConstant::GoTo.token_deploy

    end

  end

  def fetch_mint_goto



  end

end
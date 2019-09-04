class FetchGoToByEconomyState < ServicesBase

  # Initialize
  #
  # * Author: Shlok
  # * Date: 23/01/2019
  # * Reviewed By:
  #
  # @param [Hash] params (mandatory)
  #
  # @return [FetchGoToByEconomyState]
  #
  def initialize(params)

    super

    @token = @params[:token]
    @client_id = @params[:client_id]
    @from_page = @params[:from_page]
    @mint_workflow = @params[:mint_workflow]

    @go_to = {}
  end

  # Fetch by economy state
  #
  # * Author: Shlok
  # * Date: 23/01/2019
  # * Reviewed By:
  #
  # @return [Result::Base]
  #
  def fetch_by_economy_state

    handle_errors_and_exceptions do

      check_token_deployment

      check_mint_progress if @go_to.blank?

      # If go_to is blank or is same as the from_page, do not redirect.
      if @go_to.blank? || @go_to[:by_screen_name] == @from_page[:by_screen_name]
        return success
      else
        return error_with_go_to('s_fgtbes_2', 'data_validation_failed', @go_to)
      end

    end

  end

  # Check whether need redirect on deployment pages.
  #
  # * Author: Alpesh
  # * Date: 23/01/2019
  # * Reviewed By:
  #
  # @return [Result::Base]
  #
  # Set @go_to
  #
  def check_token_deployment

    if @token.blank? || @token[:status] == GlobalConstant::ClientToken.not_deployed

      @go_to = GlobalConstant::GoTo.token_setup

    elsif @token[:status] == GlobalConstant::ClientToken.deployment_started

      if @from_page[:by_screen_name] != GlobalConstant::GoTo.developer[:by_screen_name]

        @go_to = GlobalConstant::GoTo.token_deploy

      end

    elsif @token[:status] == GlobalConstant::ClientToken.deployment_failed

      @go_to = GlobalConstant::GoTo.token_deploy

    elsif @token[:status] == GlobalConstant::ClientToken.deployment_completed

      if @from_page[:by_screen_name] == GlobalConstant::GoTo.token_deploy[:by_screen_name] ||
        @from_page[:by_screen_name] == GlobalConstant::GoTo.token_setup[:by_screen_name]

        @go_to = GlobalConstant::GoTo.token_mint

      end

    end

    success

  end

  # Check whether need redirect on mint pages.
  #
  # * Author: Alpesh
  # * Date: 23/01/2019
  # * Reviewed By:
  #
  # @return [Result::Base]
  #
  # Set @go_to
  #
  def check_mint_progress

    return success if @from_page[:by_screen_name] != GlobalConstant::GoTo.token_mint[:by_screen_name] &&
      @from_page[:by_screen_name] != GlobalConstant::GoTo.token_mint_progress[:by_screen_name]

    if @mint_workflow.present? &&
      (@mint_workflow.status == GlobalConstant::Workflow.in_progress || @mint_workflow.status == GlobalConstant::Workflow.failed)

      @go_to = GlobalConstant::GoTo.token_mint_progress

    else

      @go_to = GlobalConstant::GoTo.token_mint

    end

    success

  end

end

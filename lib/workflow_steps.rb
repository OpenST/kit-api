class WorkflowSteps

  include Util::ResultHelper

  # Initialize
  #
  # * Author: Anagha
  # * Date: 15/01/2019
  # * Reviewed By:
  #
  # @params [Integer] parent_id (mandatory) - workflow parent Id
  #
  # @return [TokenSetup::SetupProgress]
  def initialize(params)

    @workflow_ids = params[:workflow_ids]

    @response_data = {}

  end


  # Perform
  #
  # * Author: Anagha
  # * Date: 15/01/2019
  # * Reviewed By:
  #
  # @return [Result::Base]
  def perform

    r = fetch_workflow_steps
    return r unless r.success?

    fetch_workflow_data
    return r unless r.success?

    r = calculate_progress
    return r unless r.success?

    success_with_data(@response_data)

  end

  # Fetch step config and group config from YML file
  #
  # * Author: Ankit
  # * Date: 15/01/2019
  # * Reviewed By:
  #
  # @return [Result::Base]
  def fetch_economy_setup_config(workflow_kind)
    case workflow_kind
    when GlobalConstant::Workflow.token_deploy
      @step_config = GlobalConstant::WorkflowStatus.economy_setup_step_config
      @group_config = GlobalConstant::WorkflowStatus.economy_setup_group_config
    when GlobalConstant::Workflow.bt_stake_and_mint
      @step_config = GlobalConstant::WorkflowStatus.bt_stake_and_mint_step_config
      @group_config = GlobalConstant::WorkflowStatus.bt_stake_and_mint_group_config
    when GlobalConstant::Workflow.grant_eth_ost
      @step_config = GlobalConstant::WorkflowStatus.grant_eth_ost_step_config
      @group_config = GlobalConstant::WorkflowStatus.grant_eth_ost_group_config
    else
      return error_with_data('l_ws_1',
                             'something_went_wrong',
                             GlobalConstant::ErrorAction.default)
    end
    success
  end


  # fetch workflow steps from db and prepare workflow data map
  #
  # {
  #   workflow_id:{kind: {`complete_row_of_that_kind`}}]
  # }
  #
  # * Author: Anagha
  # * Date: 15/01/2019
  # * Reviewed By:
  #
  # @return [Result::Base]
  #
  def fetch_workflow_steps
    @workflow_steps_data_map = {}
    workflow_step_data = WorkflowStep.where(workflow_id: @workflow_ids).order('id ASC').all
    workflow_step_data.each do |a|
      @workflow_steps_data_map[a.workflow_id] ||= {}
      @workflow_steps_data_map[a.workflow_id][a.kind] = a
    end
    success
  end

  def fetch_workflow_data
    @workflow_data_map = KitSaasSharedCacheManagement::Workflow.new(@workflow_steps_data_map.keys).fetch
    success
  end

  # calculate progress percentage depending on the status of workflow
  #
  # * Author: Anagha
  # * Date: 15/01/2019
  # * Reviewed By:
  #
  # @return [Result::Base]
  #
  def calculate_progress

    @workflow_steps_data_map.each do |workflow_id,kind_to_data_map|
      percentage_completed = 0

      workflow_kind = @workflow_data_map[workflow_id][:kind]
      r = fetch_economy_setup_config(workflow_kind)
      return r unless r.success?

      display_text = ''
      display_name = ''
      all_steps = {}
      @step_config.each do |step|
        step_group_display_text = @group_config[step['group']]['display_text']
        step_group_name = @group_config[step['group']]['name']

        all_steps[step['group']] ||= {
          display_text: step_group_display_text,
          name: step_group_name,
          status: @workflow_data_map[workflow_id].status
        }

        if kind_to_data_map[step['kind']]
          if kind_to_data_map[step['kind']].status == GlobalConstant::WorkflowStep.processed_status
            percentage_completed = percentage_completed + step['weight']
          elsif kind_to_data_map[step['kind']].status == GlobalConstant::WorkflowStep.queued_status || kind_to_data_map[step['kind']].status == GlobalConstant::WorkflowStep.pending_status

            display_text = step_group_display_text
            display_name = step_group_name
          end
        end
      end

      @response_data[workflow_id] = {
        current_step: {
          display_text: display_text,
          name: display_name,
          percent_completion: percentage_completed,
          status: @workflow_data_map[workflow_id].status
        },
        all_steps: all_steps.values
      }
    end

    success
  end
end
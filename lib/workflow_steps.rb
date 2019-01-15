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

    @workflow_id = params[:workflow_id]

    @response_data = {}

  end

  # Fetch step config and group config from YML file
  #
  # * Author: Anagha
  # * Date: 15/01/2019
  # * Reviewed By:
  #
  # @return [Result::Base]
  def fetch_economy_setup_config
    @step_config = GlobalConstant::WorkflowStatus.step_config
    @group_config = GlobalConstant::WorkflowStatus.group_config
  end

  # Perform
  #
  # * Author: Anagha
  # * Date: 15/01/2019
  # * Reviewed By:
  #
  # @return [Result::Base]
  def perform


    fetch_economy_setup_config

    r = fetch_workflow_steps
    return r unless r.success?

    r = calculate_progress
    return r unless r.success?

    success_with_data(@response_data)

  end


  # fetch workflow steps from db
  #
  # * Author: Anagha
  # * Date: 15/01/2019
  # * Reviewed By:
  #
  # @return [Result::Base]
  #
  def fetch_workflow_steps
    @workflow_data_map = {}
    workflow_step_data = WorkflowStep.where('parent_id = ? OR id = ?', @workflow_id, @workflow_id).order('id ASC').all
    workflow_step_data.each do |a|
      @workflow_data_map[a.kind] = a
      #Todo : add validation of client_id
    end
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
    percentage_completed = 0
    display_text = ''

    @step_config.each do |step|
      if @workflow_data_map[step['kind']]
        if @workflow_data_map[step['kind']].status == GlobalConstant::WorkflowStep.processed_status
          percentage_completed = percentage_completed + step['weight']
        elsif ((@workflow_data_map[step['kind']].status == GlobalConstant::WorkflowStep.queued_status || @workflow_data_map[step['kind']].status == GlobalConstant::WorkflowStep.pending_status))
          display_text = @group_config[step['group']]
        end
      end
    end

    @response_data['display_text'] = display_text
    @response_data['percent_completion'] = percentage_completed

    success
  end
end
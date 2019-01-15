module TokenSetup
  class SetupProgress < ServicesBase

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

      super

      @parent_id = params[:parent_id]

      fetch_economy_setup_config

      @api_response_data = {}

    end

    # Fetch step config and group config from YML file
    #
    # * Author: Anagha
    # * Date: 15/01/2019
    # * Reviewed By:
    #
    # @return [Result::Base]
    def fetch_economy_setup_config
      template = ERB.new File.new("#{Rails.root}/config/economy_setup.yml").read
      @step_config = YAML.load(template.result(binding))['step_config']
      @group_config = YAML.load(template.result(binding))['group_config']
    end

    # Perform
    #
    # * Author: Anagha
    # * Date: 15/01/2019
    # * Reviewed By:
    #
    # @return [Result::Base]
    def perform
      handle_errors_and_exceptions do

        r = validate_and_sanitize
        return r unless r.success?

        r = fetch_workflow_steps
        return r unless r.success?

        r = calculate_progress
        return r unless r.success?

        return success_with_data(@api_response_data)
      end
    end

    #private

    # Validate and sanitize
    #
    # * Author: Anagha
    # * Date: 15/01/2019
    # * Reviewed By:
    #
    # @return [Result::Base]
    #
    def validate_and_sanitize

      r = validate
      return r unless r.success?

      success
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
      workflowStepData = WorkflowStep.where('parent_id = ? OR id = ?', @parent_id, @parent_id).order('kind ASC').all
      workflowStepData.each do |a|
        @workflow_data_map[a.kind] = a
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
          if (@workflow_data_map[step['kind']].status == GlobalConstant::WorkflowStep.processed_status)
            percentage_completed = percentage_completed + step['weight']
          end
          if ((@workflow_data_map[step['kind']].status == GlobalConstant::WorkflowStep.queued_status || @workflow_data_map[step['kind']].status == GlobalConstant::WorkflowStep.pending_status))
            display_text = @group_config[step['group']]
          end
        end
      end

      @api_response_data['display_text'] = display_text
      @api_response_data['percent_completion'] = percentage_completed

      success
    end
  end

end



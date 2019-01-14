module TokenSetup
  class SetupProgress < ServicesBase

    ##
    #
    #
    #
    def initialize(params)

      super

      @parent_id = params[:parent_id]
      Rails.logger.info("Parent ID: #{@parent_id}")
      template = ERB.new File.new("#{Rails.root}/config/economy_setup.yml").read
      @step_config = YAML.load(template.result(binding))['step_config']
      @group_config = YAML.load(template.result(binding))['group_config']
    end

    def perform
      handle_errors_and_exceptions do
        r = validate_and_sanitize
        return r unless r.success?
      end
    end

    def validate_and_sanitize
      #Todo: add validation for input
      success
    end

    def fetch_workflow_steps
      Rails.logger.info("Parent ID: #{@parent_id}")
      @workflow_data_map = {}
      workflowStepData = WorkflowStep.where('parent_id = ? OR id = ?', @parent_id, @parent_id).order('kind ASC').all
      workflowStepData.each do |a|
        @workflow_data_map[a.kind] = a
      end
      Rails.logger.info("Group Config: #{@workflow_data_map}")
    end

    def calculate_progress

      percentage_completed = 0
      display_text = nil
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


      puts percentage_completed
      puts display_text
      @api_response_data = {}

      success
    end


  end

end



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
      Rails.logger.info("Step Config: #{@step_config}")
      Rails.logger.info("Group Config: #{@group_config}")
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
      @step_config.each do |a|
        #if(@workflow_data_map[a] && a.status == )

       # end
      end
    end


  end

end



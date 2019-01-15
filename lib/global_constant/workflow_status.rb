# frozen_string_literal: true
module GlobalConstant

  class WorkflowStatus

    class << self

      def step_config
        config['step_config']
      end

      def group_config
        config['group_config']
      end

      def token_deploy_workflow_kind
        'token_deploy'
      end

      private_class_method

      def config
        @cnf ||= begin
          template = ERB.new File.new("#{Rails.root}/config/economy_setup.yml").read
          YAML.load(template.result(binding))
        end
      end

    end

  end

end

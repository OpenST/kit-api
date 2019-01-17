# frozen_string_literal: true
module GlobalConstant

  class WorkflowStatus

    class << self

      def economy_setup_step_config
        economy_setup_config['step_config']
      end

      def economy_setup_group_config
        economy_setup_config['group_config']
      end

      def token_deploy_workflow_kind
        'token_deploy'
      end

      private_class_method

      def economy_setup_config
        @escnf ||= begin
          template = ERB.new File.new("#{Rails.root}/config/economy_setup.yml").read
          YAML.load(template.result(binding))
        end
      end

    end

  end

end

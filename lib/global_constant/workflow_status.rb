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

      def bt_stake_and_mint_step_config
        bt_stake_and_mint_config['step_config']
      end

      def bt_stake_and_mint_group_config
        bt_stake_and_mint_config['group_config']
      end

      def grant_eth_stake_currency_step_config
        grant_eth_stake_currency_config['step_config']
      end

      def grant_eth_stake_currency_group_config
        grant_eth_stake_currency_config['group_config']
      end


      private

      def economy_setup_config
        @escnf ||= begin
          template = ERB.new File.new("#{Rails.root}/config/workflow_step/economy_setup.yml").read
          YAML.load(template.result(binding))
        end
      end

      def bt_stake_and_mint_config
        @btsnmcnf ||= begin
          template = ERB.new File.new("#{Rails.root}/config/workflow_step/bt_stake_and_mint.yml").read
          YAML.load(template.result(binding))
        end
      end

      def grant_eth_stake_currency_config
        @grantethstakecurrency ||= begin
          template = ERB.new File.new("#{Rails.root}/config/workflow_step/grant_eth_stake_currency.yml").read
          YAML.load(template.result(binding))
        end
      end

    end

  end

end

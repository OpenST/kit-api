module GlobalConstant

  class WorkflowStep

    class << self

      def queued_status
        'queued'
      end

      def pending_status
        'pending'
      end

      def processed_status
        'processed'
      end

      def failed_status
        'failed'
      end

      def timeout_status
        'timeOut'
      end

      def economy_setup_init_kind
        'economySetupInit'
      end

      def generate_token_addresses_kind
        'generateTokenAddresses'
      end

      def deploy_origin_token_organization_kind
        'deployOriginTokenOrganization'
      end

      def deploy_aux_token_organization_kind
        'deployAuxTokenOrganization'
      end

      def deploy_origin_branded_token_kind
        'deployOriginBrandedToken'
      end

      def deploy_utility_branded_token_kind
        'deployUtilityBrandedToken'
      end

      def token_deploy_gateway_kind
        'tokenDeployGateway'
      end

      def token_deploy_co_gateway_kind
        'tokenDeployCoGateway'
      end

      def activate_token_gateway_kind
        'activateTokenGateway'
      end

      def set_co_gateway_in_ubt_kind
        'setCoGatewayInUbt'
      end

      def set_gateway_in_bt_kind
        'setGatewayInBt'
      end

      def token_deployment_completed
        'tokenDeploymentCompleted'
      end

      def token_deployment_failed
        'tokenDeploymentFailed'
      end

    end

  end

end
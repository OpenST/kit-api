module GlobalConstant

  class WorkflowStep

    class << self

      #Workflow step status: start
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
      #Workflow step status: finish

      #workflow economy setup kind: start
      def economy_setup_init_kind
        'economySetupInit'
      end

      def generate_token_addresses_kind
        'generateTokenAddresses'
      end

      def deploy_origin_token_organization_kind
        'deployOriginTokenOrganization'
      end

      def save_origin_token_organization_kind
        'saveOriginTokenOrganization'
      end

      def deploy_aux_token_organization_kind
        'deployAuxTokenOrganization'
      end

      def save_aux_token_organization_kind
        'saveAuxTokenOrganization'
      end

      def deploy_origin_branded_token_kind
        'deployOriginBrandedToken'
      end

      def save_origin_token_branded_token_kind
        'saveOriginBrandedToken'
      end

      def deploy_utility_branded_token_kind
        'deployUtilityBrandedToken'
      end

      def save_utility_branded_token_kind
        'saveUtilityBrandedToken'
      end

      def token_deploy_gateway_kind
        'tokenDeployGateway'
      end

      def save_token_gateway_kind
        'saveTokenGateway'
      end

      def token_deploy_co_gateway_kind
        'tokenDeployCoGateway'
      end

      def save_token_co_gateway_kind
        'saveTokenCoGateway'
      end

      def update_token_in_ost_view
        'updateTokenInOstView'
      end

      def activate_token_gateway_kind
        'activateTokenGateway'
      end

      def verify_activate_token_gateway
        'verifyActivateTokenGateway'
      end

      def set_co_gateway_in_ubt_kind
        'setCoGatewayInUbt'
      end

      def verify_set_co_gateway_in_ubt
        'verifySetCoGatewayInUbt'
      end

      def set_gateway_in_bt_kind
        'setGatewayInBt'
      end

      def verify_set_gateway_in_bt
        'verifySetGatewayInBt'
      end

      def deploy_gateway_composer
        'deployGatewayComposer'
      end

      def verify_deploy_gateway_composer
        'verifyDeployGatewayComposer'
      end

      def set_internal_actor_for_owner_in_ubt
        'setInternalActorForOwnerInUBT'
      end

      def verify_set_internal_actor_for_owner_in_ubt
        'verifySetInternalActorForOwnerInUBT'
      end

      def verify_economy_setup
        'verifyEconomySetup'
      end
      # workflow economy setup kind: finish

      # workflow economy setup kind : State root sync steps start
      def commit_state_root_init
        'commitStateRootInit'
      end

      def commit_state_root
        'commitStateRoot'
      end

      def update_committed_state_root_info
        'updateCommittedStateRootInfo'
      end
      # workflow economy setup kind : State root sync steps finish



      # ST prime stake and mint steps: start
      def st_prime_stake_and_mint_init
        'stPrimeStakeAndMintInit'
      end

      def st_prime_approve
        'stPrimeApprove'
      end

      def simple_token_stake
        'simpleTokenStake'
      end

      def fetch_stake_intent_message_hash
        'fetchStakeIntentMessageHash'
      end

      def prove_gateway_on_co_gateway
        'proveGatewayOnCoGateway'
      end

      def confirm_stake_intent
        'confirmStakeIntent'
      end

      def progress_stake
        'progressStake'
      end

      def progress_mint
        'progressMint'
      end

      def check_approve_status
        'checkApproveStatus'
      end

      def check_stake_status
        'checkStakeStatus'
      end

      def check_prove_gateway_status
        'checkProveGatewayStatus'
      end

      def check_confirm_stake_status
        'checkConfirmStakeStatus'
      end

      def check_progress_stake_status
        'checkProgressStakeStatus'
      end

      def check_progress_mint_status
        'checkProgressMintStatus'
      end
      # ST prime stake and mint steps: finish




      def token_deployment_completed
        'tokenDeploymentCompleted'
      end

      def token_deployment_failed
        'tokenDeploymentFailed'
      end

    end

  end

end
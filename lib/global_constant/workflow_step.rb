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

      def generate_tx_worker_addresses_kind
        'generateTxWorkerAddresses'
      end

      def fund_aux_funder_addr_kind
        'fundAuxFunderAddress'
      end

      def verify_fund_aux_funder_addr_kind
        'verifyFundAuxFunderAddress'
      end

      def fund_ex_tx_workers_kind
        'fundExTxWorkers'
      end

      def fund_aux_admin_addr_kind
        'fundAuxAdminAddress'
      end

      def verify_fund_aux_admin_addr_kind
        'verifyFundAuxAdminAddress'
      end

      def fund_aux_worker_addr_kind
        'fundAuxWorkerAddress'
      end

      def verify_fund_aux_worker_addr_kind
        'verifyFundAuxWorkerAddress'
      end

      def fund_token_user_ops_worker
        'fundTokenUserOpsWorker'
      end
      
      def verify_fund_token_user_ops_worker
        'verifyFundTokenUserOpsWorker'
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

      def set_internal_actor_for_facilitator_in_ubt
        'setInternalActorForFacilitatorInUBT'
      end

      def verify_set_internal_actor_for_facilitator_in_ubt
        'verifySetInternalActorForFacilitatorInUBT'
      end

      def assign_shards
        'assignShards'
      end
      
      def deploy_token_rules
        'deployTokenRules'
      end

      def save_token_rules
        'saveTokenRules'
      end
      
      def deploy_token_holder_master_copy
        'deployTokenHolderMasterCopy'
      end

      def save_token_holder_master_copy
        'saveTokenHolderMasterCopy'
      end
      
      def deploy_user_wallet_factory
        'deployUserWalletFactory'
      end

      def save_user_wallet_factory
        'saveUserWalletFactory'
      end
      
      def deploy_gnosis_safe_multi_sig_master_copy
        'deployGnosisSafeMultiSigMasterCopy'
      end

      def save_gnosis_safe_multi_sig_master_copy
        'saveGnosisSafeMultiSigMasterCopy'
      end

      def deploy_delayed_recovery_master_copy
        'deployDelayedRecoveryModuleMasterCopy'
      end

      def save_deploy_delayed_recovery_master_copy
        'saveDelayedRecoveryModuleMasterCopy'
      end

      def deploy_create_and_add_modules
        'deployCreateAndAddModules'
      end

      def save_deploy_create_and_add_modules
        'saveCreateAndAddModules'
      end

      def fund_recovery_controller_address
        'fundRecoveryControllerAddress'
      end
      
      def deploy_pricer_rule
        'deployPricerRule'
      end

      def save_pricer_rule
        'savePricerRule'
      end
      
      def register_pricer_rule
        'registerPricerRule'
      end

      def verify_register_pricer_rule
        'verifyRegisterPricerRule'
      end
      
      def add_price_oracle_in_pricer_rule
        'addPriceOracleInPricerRule'
      end

      def verify_add_price_oracle_in_pricer_rule
        'verifyAddPriceOracleInPricerRule'
      end
      
      def set_accepted_margin_in_pricer_rule
        'setAcceptedMarginInPricerRule'
      end

      def verify_set_accepted_margin_in_pricer_rule
        'verifySetAcceptedMarginInPricerRule'
      end

      def post_token_rules_deploy
        'post_token_rules_deploy'
      end
      
      def deploy_proxy_factory
        'deployProxyFactory'
      end

      def save_proxy_factory
        'saveProxyFactory'
      end

      def initialize_company_token_holder_in_db
        'initializeCompanyTokenHolderInDb'
      end
      
      def create_company_wallet
        'createCompanyWallet'
      end

      def verify_create_company_wallet
        'verifyCreateCompanyWallet'
      end
      
      def set_internal_actor_for_companyTH_in_UBT
        'setInternalActorForCompanyTHInUBT'
      end

      def verify_set_internal_actor_for_companyTH_in_UBT
        'verifySetInternalActorForCompanyTHInUBT'
      end

      def generate_tx_worker_addresses
        'generate_tx_worker_addresses'
      end

      def fund_ex_tx_workers
        'fundExTxWorkers'
      end
      
      def set_internal_actor_for_TR_in_UBT
        'setInternalActorForTRInUBT'
      end

      def verify_set_internal_actor_for_TR_in_UBT
        'verifySetInternalActorForTRInUBT'
      end
      
      def verify_economy_setup
        'verifyEconomySetup'
      end

      def send_token_setup_success_email
        'sendTokenSetupSuccessEmail'
      end

      def send_token_setup_error_email
        'sendTokenSetupErrorEmail'
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

      # Bt stake and mint steps: start

      def bt_stake_and_mint_init
        'btStakeAndMintInit'
      end

      def approve_gateway_composer_trx
        'approveGatewayComposerTrx'
      end

      def staker_request_stake_trx
        'stakerRequestStakeTrx'
      end

      def check_gc_allowance
        'checkGatewayComposerAllowance'
      end

      def fetch_stake_request_hash
        'fetchStakeRequestHash'
      end

      def accept_stake
        'acceptStake'
      end

      def send_stake_and_mint_success_email
        'sendStakeAndMintSuccessEmail'
      end

      def send_stake_and_mint_error_email
        'sendStakeAndMintErrorEmail'
      end

      # Bt stake and mint steps: finish

      # Grant Eth Ost steps: start
      def grant_eth_ost_init
        'grant_eth_ost_init'
      end

      def grant_eth
        'grant_eth'
      end

      def verify_grant_eth
        'verify_grant_eth'
      end

      def grant_ost
        'grant_ost'
      end

      def verify_grant_ost
        'verify_grant_ost'
      end

      # Grant Eth Ost steps: finish

      # Common Steps start

      def mark_success
        'markSuccess'
      end

      def mark_failure
        'markFailure'
      end
      # Common steps finish

      def token_deployment_completed
        'tokenDeploymentCompleted'
      end

      def token_deployment_failed
        'tokenDeploymentFailed'
      end

    end

  end

end
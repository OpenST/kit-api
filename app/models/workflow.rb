class Workflow < DbConnection::KitSaasSubenv

  enum kind: {
    GlobalConstant::Workflow.token_deploy => 1,
    GlobalConstant::Workflow.state_root_sync => 2,
    GlobalConstant::Workflow.st_prime_stake_and_mint => 3,
    GlobalConstant::Workflow.bt_stake_and_mint => 4,
    GlobalConstant::Workflow.grant_eth_stake_currency => 5,
    GlobalConstant::Workflow.setup_user => 6,
    GlobalConstant::Workflow.test => 7,
    GlobalConstant::Workflow.authorize_device => 8,
    GlobalConstant::Workflow.authorize_session => 9,
    GlobalConstant::Workflow.revoke_device => 10,
    GlobalConstant::Workflow.revoke_session => 11,
    GlobalConstant::Workflow.initiate_recovery => 12,
    GlobalConstant::Workflow.abort_recovery_by_owner => 13,
    GlobalConstant::Workflow.reset_recovery_owner => 14,
    GlobalConstant::Workflow.execute_recovery => 15,
    GlobalConstant::Workflow.abort_recovery_by_recovery_controller => 16,
    GlobalConstant::Workflow.logout_sessions => 17,
    GlobalConstant::Workflow.st_prime_redeem_and_unstake => 18,
    GlobalConstant::Workflow.bt_redeem_and_unstake => 19,
    GlobalConstant::Workflow.update_price_point => 20
  }

  enum status: {
    GlobalConstant::Workflow.in_progress => 1,
    GlobalConstant::Workflow.completed => 2,
    GlobalConstant::Workflow.failed => 3,
    GlobalConstant::Workflow.completely_failed => 4
  }
end

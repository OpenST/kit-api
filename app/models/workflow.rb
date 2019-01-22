class Workflow < DbConnection::KitSaasSubenv

  enum kind: {
    GlobalConstant::Workflow.token_deploy => 1,
    GlobalConstant::Workflow.state_root_sync => 2,
    GlobalConstant::Workflow.stake_and_mint => 4
  }

  enum status: {
    GlobalConstant::Workflow.in_progress => 1,
    GlobalConstant::Workflow.completed => 2,
    GlobalConstant::Workflow.failed => 3,
    GlobalConstant::Workflow.completely_failed => 4
  }
end
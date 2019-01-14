class WorkflowStep < DbConnection::KitSaasSubenv
  
  enum kind: {
      GlobalConstant::WorkflowStep.economy_setup_init_kind => 1,
      GlobalConstant::WorkflowStep.generate_token_addresses_kind => 2,
      GlobalConstant::WorkflowStep.deploy_origin_branded_token_kind => 3,
      GlobalConstant::WorkflowStep.deploy_origin_branded_token_kind => 4,
      GlobalConstant::WorkflowStep.deploy_aux_token_organization_kind => 5,
      GlobalConstant::WorkflowStep.deploy_utility_branded_token_kind => 6,
      GlobalConstant::WorkflowStep.token_deploy_gateway_kind => 7,
      GlobalConstant::WorkflowStep.token_deploy_co_gateway_kind => 8,
      GlobalConstant::WorkflowStep.activate_token_gateway_kind => 9,
      GlobalConstant::WorkflowStep.set_co_gateway_in_ubt_kind => 10,
      GlobalConstant::WorkflowStep.set_gateway_in_bt_kind => 11
  }

  enum status: {
    GlobalConstant::WorkflowStep.queued_status => 1,
    GlobalConstant::WorkflowStep.pending_status => 2,
    GlobalConstant::WorkflowStep.processed_status => 3,
    GlobalConstant::WorkflowStep.failed_status => 4,
    GlobalConstant::WorkflowStep.timeout_status => 5
  }

end
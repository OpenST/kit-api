class WorkflowStep < DbConnection::KitSaasSubenv
  
  enum kind: {
      GlobalConstant::WorkflowStep.economy_setup_init_kind => 1,
      GlobalConstant::WorkflowStep.generate_token_addresses_kind => 2,
      GlobalConstant::WorkflowStep.deploy_origin_token_organization_kind => 3,
      GlobalConstant::WorkflowStep.save_origin_token_organization_kind => 4,
      GlobalConstant::WorkflowStep.deploy_origin_branded_token_kind => 5,
      GlobalConstant::WorkflowStep.save_origin_token_branded_token_kind => 6,
      GlobalConstant::WorkflowStep.deploy_aux_token_organization_kind => 7,
      GlobalConstant::WorkflowStep.save_aux_token_organization_kind => 8,
      GlobalConstant::WorkflowStep.deploy_utility_branded_token_kind => 9,
      GlobalConstant::WorkflowStep.save_utility_branded_token_kind => 10,
      GlobalConstant::WorkflowStep.token_deploy_gateway_kind => 11,
      GlobalConstant::WorkflowStep.save_token_gateway_kind => 12,
      GlobalConstant::WorkflowStep.update_token_in_ost_view => 13,
      GlobalConstant::WorkflowStep.token_deploy_co_gateway_kind => 14,
      GlobalConstant::WorkflowStep.save_token_co_gateway_kind => 15,
      GlobalConstant::WorkflowStep.activate_token_gateway_kind => 16,
      GlobalConstant::WorkflowStep.verify_activate_token_gateway => 17,
      GlobalConstant::WorkflowStep.set_gateway_in_bt_kind => 18,
      GlobalConstant::WorkflowStep.verify_set_gateway_in_bt => 19,
      GlobalConstant::WorkflowStep.set_co_gateway_in_ubt_kind => 20,
      GlobalConstant::WorkflowStep.verify_set_co_gateway_in_ubt => 21,
      GlobalConstant::WorkflowStep.deploy_gateway_composer => 22,
      GlobalConstant::WorkflowStep.verify_deploy_gateway_composer => 23,
      GlobalConstant::WorkflowStep.set_internal_actor_for_owner_in_ubt => 24,
      GlobalConstant::WorkflowStep.verify_set_internal_actor_for_owner_in_ubt => 25,
      GlobalConstant::WorkflowStep.verify_economy_setup => 26,

  }

  enum status: {
    GlobalConstant::WorkflowStep.queued_status => 1,
    GlobalConstant::WorkflowStep.pending_status => 2,
    GlobalConstant::WorkflowStep.processed_status => 3,
    GlobalConstant::WorkflowStep.failed_status => 4,
    GlobalConstant::WorkflowStep.timeout_status => 5
  }

end
class WorkflowStep < DbConnection::KitSaasSubenv
  
  enum kind: {
      GlobalConstant::WorkflowStep.economy_setup_init_kind => 1,
      GlobalConstant::WorkflowStep.generate_token_addresses_kind => 2,
      GlobalConstant::WorkflowStep.fund_aux_funder_addr_kind => 3,
      GlobalConstant::WorkflowStep.verify_fund_aux_funder_addr_kind => 4,
      GlobalConstant::WorkflowStep.fund_aux_admin_addr_kind => 5,
      GlobalConstant::WorkflowStep.verify_fund_aux_admin_addr_kind => 6,
      GlobalConstant::WorkflowStep.fund_aux_worker_addr_kind => 7,
      GlobalConstant::WorkflowStep.verify_fund_aux_worker_addr_kind => 8,
      GlobalConstant::WorkflowStep.deploy_origin_token_organization_kind => 9,
      GlobalConstant::WorkflowStep.save_origin_token_organization_kind => 10,
      GlobalConstant::WorkflowStep.deploy_origin_branded_token_kind => 11,
      GlobalConstant::WorkflowStep.save_origin_token_branded_token_kind => 12,
      GlobalConstant::WorkflowStep.deploy_aux_token_organization_kind => 13,
      GlobalConstant::WorkflowStep.save_aux_token_organization_kind => 14,
      GlobalConstant::WorkflowStep.deploy_utility_branded_token_kind => 15,
      GlobalConstant::WorkflowStep.save_utility_branded_token_kind => 16,
      GlobalConstant::WorkflowStep.token_deploy_gateway_kind => 17,
      GlobalConstant::WorkflowStep.save_token_gateway_kind => 18,
      GlobalConstant::WorkflowStep.update_token_in_ost_view => 19,
      GlobalConstant::WorkflowStep.token_deploy_co_gateway_kind => 20,
      GlobalConstant::WorkflowStep.save_token_co_gateway_kind => 21,
      GlobalConstant::WorkflowStep.activate_token_gateway_kind => 22,
      GlobalConstant::WorkflowStep.verify_activate_token_gateway => 23,
      GlobalConstant::WorkflowStep.set_gateway_in_bt_kind => 24,
      GlobalConstant::WorkflowStep.verify_set_gateway_in_bt => 25,
      GlobalConstant::WorkflowStep.set_co_gateway_in_ubt_kind => 26,
      GlobalConstant::WorkflowStep.verify_set_co_gateway_in_ubt => 27,
      GlobalConstant::WorkflowStep.deploy_gateway_composer => 28,
      GlobalConstant::WorkflowStep.verify_deploy_gateway_composer => 29,
      GlobalConstant::WorkflowStep.set_internal_actor_for_owner_in_ubt => 30,
      GlobalConstant::WorkflowStep.verify_set_internal_actor_for_owner_in_ubt => 31,
      GlobalConstant::WorkflowStep.verify_economy_setup => 32,

      GlobalConstant::WorkflowStep.mark_success => 101



  }

  enum status: {
    GlobalConstant::WorkflowStep.queued_status => 1,
    GlobalConstant::WorkflowStep.pending_status => 2,
    GlobalConstant::WorkflowStep.processed_status => 3,
    GlobalConstant::WorkflowStep.failed_status => 4,
    GlobalConstant::WorkflowStep.timeout_status => 5
  }

end
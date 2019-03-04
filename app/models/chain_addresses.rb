class ChainAddresses < DbConnection::KitSaasSubenv

  include Util::ResultHelper
  
  enum kind: {

    GlobalConstant::ChainAddresses.aux_deployer_kind => 1,
    GlobalConstant::ChainAddresses.origin_deployer_kind => 2,
    GlobalConstant::ChainAddresses.st_contract_owner_kind => 3,
    GlobalConstant::ChainAddresses.st_contract_admin_kind => 4,
    GlobalConstant::ChainAddresses.st_contract_kind => 5,
    GlobalConstant::ChainAddresses.st_prime_contract_kind => 6,
    GlobalConstant::ChainAddresses.st_org_contract_kind => 7,
    GlobalConstant::ChainAddresses.st_prime_org_contract_kind => 8,
    GlobalConstant::ChainAddresses.master_internal_funder_kind => 9,
    GlobalConstant::ChainAddresses.st_org_contract_owner_kind => 10,
    GlobalConstant::ChainAddresses.st_prime_org_contract_owner_kind => 11,
    GlobalConstant::ChainAddresses.origin_anchor_org_contract_owner_kind => 12,
    GlobalConstant::ChainAddresses.aux_anchor_org_contract_owner_kind => 13,
    GlobalConstant::ChainAddresses.aux_price_oracle_contract_owner_kind => 14,
    GlobalConstant::ChainAddresses.st_org_contract_admin_kind => 15,
    GlobalConstant::ChainAddresses.st_prime_org_contract_admin_kind => 16,
    GlobalConstant::ChainAddresses.origin_anchor_org_contract_admin_kind => 17,
    GlobalConstant::ChainAddresses.aux_anchor_org_contract_admin_kind => 18,
    GlobalConstant::ChainAddresses.aux_price_oracle_contract_admin_kind => 19,
    GlobalConstant::ChainAddresses.st_org_contract_worker_kind => 20,
    GlobalConstant::ChainAddresses.st_prime_org_contract_worker_kind => 21,
    GlobalConstant::ChainAddresses.origin_anchor_org_contract_worker_kind => 22,
    GlobalConstant::ChainAddresses.aux_anchor_org_contract_worker_kind => 23,
    GlobalConstant::ChainAddresses.origin_anchor_org_contract_kind => 24,
    GlobalConstant::ChainAddresses.aux_anchor_org_contract_kind => 25,
    GlobalConstant::ChainAddresses.origin_anchor_contract_kind => 26,
    GlobalConstant::ChainAddresses.aux_anchor_contract_kind => 27,
    GlobalConstant::ChainAddresses.origin_mpp_lib_contract_kind => 28,
    GlobalConstant::ChainAddresses.aux_mpp_lib_contract_kind => 29,
    GlobalConstant::ChainAddresses.origin_mb_lib_contract_kind => 30,
    GlobalConstant::ChainAddresses.aux_mb_lib_contract_kind => 31,
    GlobalConstant::ChainAddresses.origin_gateway_lib_contract_kind => 32,
    GlobalConstant::ChainAddresses.aux_gateway_lib_contract_kind => 33,
    GlobalConstant::ChainAddresses.origin_gateway_contract_kind => 34,
    GlobalConstant::ChainAddresses.aux_co_gateway_contract_kind => 35,
    GlobalConstant::ChainAddresses.aux_sealer_kind => 36,
    GlobalConstant::ChainAddresses.st_simple_stake_contract_kind => 37,
    GlobalConstant::ChainAddresses.origin_granter_kind => 38,
    GlobalConstant::ChainAddresses.origin_default_bt_org_contract_admin_kind => 39,
    GlobalConstant::ChainAddresses.origin_default_bt_org_contract_worker_kind => 40,
    GlobalConstant::ChainAddresses.inter_chain_facilitator_kind => 41,
    GlobalConstant::ChainAddresses.aux_price_oracle_contract_kind => 42,
    GlobalConstant::ChainAddresses.aux_price_oracle_contract_worker_kind => 43
  }

  enum status: {
    GlobalConstant::ChainAddresses.active_status => 1,
    GlobalConstant::ChainAddresses.inactive_status => 2,
  }

  # Format data to a format which goes into cache
  #
  # * Author: Dhananjay
  # * Date: 20/12/2018
  # * Reviewed By:
  #
  # @return [Hash]
  #
  def formated_cache_data
    {
      token_id: token_id,
      kind: kind,
      address: address,
      known_address_id: known_address_id
    }
  end
end
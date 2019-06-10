class ChainAddresses < DbConnection::KitSaasSubenv

  include Util::ResultHelper
  
  enum kind: {

    GlobalConstant::ChainAddresses.aux_deployer_kind => 1,
    GlobalConstant::ChainAddresses.origin_deployer_kind => 2,
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
  # * Author: Shlok
  # * Date: 04/03/2019
  # * Reviewed By:
  #
  # @return [Hash]
  #
  def formatted_cache_data
    {
      deployed_chain_id: deployed_chain_id,
      kind: kind,
      deployed_chain_kind: deployed_chain_kind,
      address: address,
      known_address_id: known_address_id
    }
  end

  # Fetch data from db.
  #
  # * Author: Shlok
  # * Date: 05/03/2019
  # * Reviewed By:
  #
  # @return [Hash]
  #
  def fetch_chain_addresses(params)
    chain_id = params[:chain_id]

    return_data = {}
    chain_addresses = ChainAddresses.where(associated_aux_chain_id: chain_id, status: GlobalConstant::ChainAddresses.active_status).all

    chain_addresses.each do |chain_address_row|

      address_kind = chain_address_row.kind

      formatted_data = {
        deployedChainId: chain_address_row.deployed_chain_id,
        deployedChainKind: chain_address_row.deployed_chain_kind,
        address: chain_address_row.address,
        knownAddressId: chain_address_row.known_address_id
      }

      if GlobalConstant::ChainAddresses.non_unique_kinds.include? address_kind
        return_data[address_kind] ||= []
        return_data[address_kind].push(formatted_data)
      else
        return_data[address_kind] = formatted_data
      end

    end

    @return_data = {}
    @return_data[chain_id] = return_data

    success_with_data(@return_data)


  end
end
class TokenAddresses < DbConnection::KitSaasSubenv

  include Util::ResultHelper
  
  enum kind: {

    GlobalConstant::TokenAddresses.owner_address_kind => 1,
    GlobalConstant::TokenAddresses.origin_admin_address_kind => 2,
    GlobalConstant::TokenAddresses.aux_admin_address_kind => 3,
    GlobalConstant::TokenAddresses.origin_worker_address_kind => 4,
    GlobalConstant::TokenAddresses.aux_worker_address_kind => 5,
    GlobalConstant::TokenAddresses.aux_funder_address_kind => 6,
    GlobalConstant::TokenAddresses.white_listed_address_kind => 7,
    GlobalConstant::TokenAddresses.tx_worker_address_kind => 8,
    GlobalConstant::TokenAddresses.token_user_ops_worker_address_kind => 9,
    GlobalConstant::TokenAddresses.recovery_controller_address_kind => 10,

    #contract kinds
    GlobalConstant::TokenAddresses.origin_organization_contract => 51,
    GlobalConstant::TokenAddresses.aux_organization_contract => 52,
    GlobalConstant::TokenAddresses.branded_token_contract => 53,
    GlobalConstant::TokenAddresses.utility_branded_token_contract => 54,
    GlobalConstant::TokenAddresses.token_gateway_contract => 55,
    GlobalConstant::TokenAddresses.token_co_gateway_contract => 56,
    GlobalConstant::TokenAddresses.simple_stake_contract => 57,
    GlobalConstant::TokenAddresses.token_rules_contract => 58,
    GlobalConstant::TokenAddresses.token_holder_master_copy_contract => 59,
    GlobalConstant::TokenAddresses.user_wallet_factory_contract => 60,
    GlobalConstant::TokenAddresses.gnosis_safe_multisig_master_copy_contract => 61,
    GlobalConstant::TokenAddresses.proxy_factory_contract => 62,
    GlobalConstant::TokenAddresses.delayed_recovery_module_master_copy_contract => 63,
    GlobalConstant::TokenAddresses.create_add_modules_contract => 64,
  }

  enum status: {
    GlobalConstant::TokenAddresses.active_status => 1,
    GlobalConstant::TokenAddresses.inactive_status => 2,
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

  def fetch_all_addresses(params)
    @token_ids = params[:token_ids]

    @return_data = {}
    token_addresses = TokenAddresses.where(token_id: @token_ids, status: GlobalConstant::TokenAddresses.active_status).all

    token_addresses.each do |token_address_row|
      @return_data[token_address_row.token_id] ||= {}
      if GlobalConstant::TokenAddresses.unique_kinds.index(token_address_row.kind)
        @return_data[token_address_row.token_id][token_address_row.kind] = token_address_row.address
      else
          @return_data[token_address_row.token_id][token_address_row.kind] ||= []
          @return_data[token_address_row.token_id][token_address_row.kind].push(token_address_row.address)
      end
    end
    success_with_data(@return_data)
  end
end
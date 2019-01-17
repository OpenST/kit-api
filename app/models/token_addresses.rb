class TokenAddresses < DbConnection::KitSaasSubenv

  include Util::ResultHelper
  
  enum kind: {

    GlobalConstant::TokenAddresses.owner_address_kind => 1,
    GlobalConstant::TokenAddresses.admin_address_kind => 2,
    GlobalConstant::TokenAddresses.worker_address_kind => 3,
    GlobalConstant::TokenAddresses.white_listed_address_kind => 4,

    #contract kinds
    GlobalConstant::TokenAddresses.origin_organization_contract => 51,
    GlobalConstant::TokenAddresses.aux_organization_contract => 52,
    GlobalConstant::TokenAddresses.branded_token_contract => 53,
    GlobalConstant::TokenAddresses.utility_branded_token_contract => 54,
    GlobalConstant::TokenAddresses.token_gateway_contract => 55,
    GlobalConstant::TokenAddresses.token_co_gateway_contract => 56,
    GlobalConstant::TokenAddresses.simple_stake_contract => 57
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
    token_addresses = TokenAddresses.where(token_id: @token_ids).all

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
class TokenAddresses < DbConnection::KitSaasSubenv
  
  enum chain_kind: {
    GlobalConstant::TokenAddresses.origin => 1,
    GlobalConstant::TokenAddresses.aux => 2
  }
  
  enum kind: {
    GlobalConstant::TokenAddresses.gateway => 1,
    GlobalConstant::TokenAddresses.co_gateway => 2,
    GlobalConstant::TokenAddresses.ubt => 3,
    GlobalConstant::TokenAddresses.owner => 4,
    GlobalConstant::TokenAddresses.funder => 5
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
      chain_kind: chain_kind,
      kind: kind,
      address: address,
      known_address_id: known_address_id
    }
  end
  
  

end
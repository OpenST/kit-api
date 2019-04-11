class StakeCurrency < DbConnection::KitSaasSubenv

# Format data to a format which goes into cache
#
# * Author: Santhosh
# * Date: 11/04/2019
# * Reviewed By:
#
# @return [Hash]
#
  def formated_cache_data
    {
        id: id,
        name: name,
        symbol: symbol,
        decimal: decimal,
        contract_address: contract_address
    }
  end

  after_commit :flush_cache

# Flush caches
#
# * Author: Santhosh
# * Date: 11/04/2019
# * Reviewed By:
#
  def flush_cache
    KitSaasSharedCacheManagement::StakeCurrencies.new([id]).clear
  end


end
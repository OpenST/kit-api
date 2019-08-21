class LatestTransaction < DbConnection::KitSaasSubenv
  after_commit :flush_cache

  # Format data to a format which goes into cache
  #
  # * Author: Puneet
  # * Date: 01/02/2018
  # * Reviewed By:
  #
  # @return [Hash]
  #
  def formatted_cache_data
    {
      id: id,
      transaction_hash: transaction_hash,
      chain_id: chain_id,
      token_id: token_id,
      tx_fees_in_wei: tx_fees_in_wei,
      token_amount_in_wei: token_amount_in_wei,
      created_ts: created_ts
    }
  end

  # Flush caches
  #
  # * Author: Puneet
  # * Date: 01/02/2018
  # * Reviewed By:
  #
  def flush_cache
    KitSaasSharedCacheManagement::LatestTransactions.new.clear
  end
end
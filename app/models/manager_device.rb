class ManagerDevice < DbConnection::KitClient

  enum status: {
      GlobalConstant::ManagerDevice.inactive_status => 1,
      GlobalConstant::ManagerDevice.active_status => 2
  }

  after_commit :flush_cache

  # Format data to a format which goes into cache
  #
  # * Author: Santhosh
  # * Date: 21/06/2019
  # * Reviewed By:
  #
  # @return [Hash]
  #
  def formatted_cache_data
    {
        id: id,
        manager_id: manager_id,
        fingerprint: fingerprint,
        fingerprint_type: fingerprint_type,
        unique_hash: unique_hash,
        expiration_timestamp: expiration_timestamp,
        status: status
    }
  end

  # Flush caches
  #
  # * Author: Santhosh
  # * Date: 21/06/2019
  # * Reviewed By:
  #
  def flush_cache
    CacheManagement::ManagerDevice.new([unique_hash]).clear
  end
end
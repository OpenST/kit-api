class Manager < DbConnection::KitClient

  enum status: {
      GlobalConstant::ManagerDevice.authorized_status => 1,
      GlobalConstant::ManagerDevice.registered_status => 2
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
        browser_fingerprint: browser_fingerprint,
        unique_hash: unique_hash,
        last_logged_in_at: last_logged_in_at,
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
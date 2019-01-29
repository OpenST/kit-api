class ClientWhitelisting < DbConnection::KitSaasSubenv

  after_commit :flush_cache

  # Format data to a format which goes into cache
  #
  # * Author: Puneet
  # * Date: 01/02/2018
  # * Reviewed By:
  #
  # @return [Hash]
  #
  def formated_cache_data
    {
      id: id
    }
  end

  # Flush memcache
  #
  # * Author: Puneet
  # * Date: 06/12/2018
  # * Reviewed By:
  #
  def flush_cache
    KitSaasSharedCacheManagement::ClientWhitelisting.new([client_id]).clear
  end

  def self.applicable_sub_environments
    [GlobalConstant::Environment.main_sub_environment]
  end

end

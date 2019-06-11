module CacheManagement

  class ManagerDeviceByUniqueHash < CacheManagement::Base

    private

    # Fetch from db
    #
    # * Author: Santhosh
    # * Date: 22/06/2019
    # * Reviewed By:
    #
    # @return [Result::Base]
    #
    def fetch_from_db(cache_miss_unique_hashes)
      data_to_cache = ::ManagerDevice.where(unique_hash: cache_miss_unique_hashes).inject({}) do |device_data, manager_device|
        device_data[manager_device.unique_hash] = manager_device.formatted_cache_data
        device_data
      end
      success_with_data(data_to_cache)
    end

    # Memcache key object
    #
    # * Author: Santhosh
    # * Date: 22/06/2019
    # * Reviewed By:
    #
    # @return [MemcacheKey]
    #
    def memcache_key_object
      @m_k_o ||= MemcacheKey.new('manager.devices')
    end

    # Fetch cache key
    #
    # * Author: Santhosh
    # * Date: 22/06/2019
    # * Reviewed By:
    #
    # @return [String]
    #
    def get_cache_key(unique_hash)
      memcache_key_object.key_template % @options.merge(u_h: unique_hash)
    end

    # Fetch cache expiry (in seconds)
    #
    # * Author: Santhosh
    # * Date: 22/06/2019
    # * Reviewed By:
    #
    # @return [Integer]
    #
    def get_cache_expiry
      memcache_key_object.expiry
    end

  end

end
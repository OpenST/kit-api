module CacheManagement

  class ManagerDeviceById < CacheManagement::Base

    private

    # Fetch from db
    #
    # * Author: Ankit
    # * Date: 28/06/2019
    # * Reviewed By:
    #
    # @return [Result::Base]
    #
    def fetch_from_db(cache_miss_ids)
      data_to_cache = ::ManagerDevice.where(id: cache_miss_ids).inject({}) do |device_data, manager_device|
        device_data[manager_device.id] = manager_device.formatted_cache_data
        device_data
      end
      success_with_data(data_to_cache)
    end

    # Memcache key object
    #
    # * Author: Ankit
    # * Date: 28/06/2019
    # * Reviewed By:
    #
    # @return [MemcacheKey]
    #
    def memcache_key_object
      @m_k_o ||= MemcacheKey.new('manager.devices_by_id')
    end

    # Fetch cache key
    #
    # * Author: Ankit
    # * Date: 28/06/2019
    # * Reviewed By:
    #
    # @return [String]
    #
    def get_cache_key(id)
      memcache_key_object.key_template % @options.merge(id: id)
    end

    # Fetch cache expiry (in seconds)
    #
    # * Author: Ankit
    # * Date: 28/06/2019
    # * Reviewed By:
    #
    # @return [Integer]
    #
    def get_cache_expiry
      memcache_key_object.expiry
    end

  end

end
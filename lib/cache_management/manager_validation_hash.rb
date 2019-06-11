module CacheManagement

  class ManagerValidationHash < CacheManagement::Base

    private

    # Fetch from db
    #
    # * Author: Dhananjay
    # * Date: 29/05/2019
    # * Reviewed By:
    #
    # @return [Result::Base]
    #
    def fetch_from_db(cache_miss_ids)
      data_to_cache = ::ManagerValidationHash.where(id: cache_miss_ids).inject({}) do |manager_validation_hash_data, manager_validation_hash|
        manager_validation_hash_data[manager_validation_hash.id] = manager_validation_hash.formatted_cache_data
        manager_validation_hash_data
      end
      success_with_data(data_to_cache)
    end

    # Fetch memcache key object
    #
    # * Author: Dhananjay
    # * Date: 29/05/2019
    # * Reviewed By:
    #
    # @return [MemcacheKey]
    #
    def memcache_key_object
      @m_k_o ||= MemcacheKey.new('manager_validation_hash.details')
    end

    # Fetch cache key
    #
    # * Author: Dhananjay
    # * Date: 29/05/2019
    # * Reviewed By:
    #
    # @return [String]
    #
    def get_cache_key(id)
      memcache_key_object.key_template % @options.merge(id: id)
    end

    # Fetch cache expiry (in seconds)
    #
    # * Author: Dhananjay
    # * Date: 29/05/2019
    # * Reviewed By:
    #
    # @return [Integer]
    #
    def get_cache_expiry
      memcache_key_object.expiry
    end

  end

end
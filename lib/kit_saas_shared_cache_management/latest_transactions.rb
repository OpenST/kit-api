module KitSaasSharedCacheManagement

  class LatestTransactions < KitSaasSharedCacheManagement::Base

    # Fetch from db
    #
    # * Author: Ankit
    # * Date: 20/08/2019
    # * Reviewed By:
    #
    # @return [Result::Base]
    #
    def fetch_from_db(id)
      rsp = LatestTransaction.select('*').order('created_ts DESC').limit(30).all.to_a
      data_to_cache = {}
      data_to_cache[id[0]] = rsp
      success_with_data(data_to_cache)
    end

    #
    # * Author: Ankit
    # * Date: 20/08/2019
    # * Reviewed By:
    #
    # @return [MemcacheKey]
    #
    def memcache_key_object
      @m_k_o ||= MemcacheKey.new('latest_transactions.details')
    end

    # Fetch cache key
    #
    # * Author: Ankit
    # * Date: 20/08/2019
    # * Reviewed By:
    #
    # @return [String]
    #
    def get_kit_cache_key(id)
      generate_kit_cache_key @options.merge(id: id)
    end

    # Fetch saas cache key
    #
    # * Author: Ankit
    # * Date: 20/08/2019
    # * Reviewed By:
    #
    # @return [String]
    #
    def get_saas_cache_key(id)
      generate_saas_cache_key @options.merge(id: id)
    end

    # Fetch cache expiry (in seconds)
    #
    # * Author: Ankit
    # * Date: 20/08/2019
    # * Reviewed By:
    #
    # @return [Integer]
    #
    def get_cache_expiry
      memcache_key_object.expiry
    end

  end
end
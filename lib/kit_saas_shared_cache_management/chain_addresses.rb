module KitSaasSharedCacheManagement

  class ChainAddresses < KitSaasSharedCacheManagement::Base

    # Fetch from db
    #
    # * Author: Shlok
    # * Date: /03/2019
    # * Reviewed By:
    #
    # @return [Result::Base]
    #
    def fetch_from_db(chain_id)
      rsp = ::ChainAddresses.new.fetch_chain_addresses({chain_id: chain_id})
      data_to_cache = rsp.data
      success_with_data(data_to_cache)
    end

    #
    # * Author: Shlok
    # * Date: /03/2019
    # * Reviewed By:
    #
    # @return [MemcacheKey]
    #
    def memcache_key_object
      @m_k_o ||= MemcacheKey.new('chain_addresses.details')
    end

    # Fetch cache key
    #
    # * Author: Shlok
    # * Date: /03/2019
    # * Reviewed By:
    #
    # @return [String]
    #
    def get_kit_cache_key(chain_id)
      generate_kit_cache_key @options.merge(chain_id: chain_id)
    end

    # Fetch saas cache key
    #
    # * Author: Shlok
    # * Date: /03/2019
    # * Reviewed By:
    #
    # @return [String]
    #
    def get_saas_cache_key(chain_id)
      generate_saas_cache_key @options.merge(chain_id: chain_id)
    end

    # Fetch cache expiry (in seconds)
    #
    # * Author: Shlok
    # * Date: /03/2019
    # * Reviewed By:
    #
    # @return [Integer]
    #
    def get_cache_expiry
      memcache_key_object.expiry
    end

  end
end
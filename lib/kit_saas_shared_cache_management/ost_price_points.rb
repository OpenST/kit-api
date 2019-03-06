module KitSaasSharedCacheManagement

  class OstPricePoints < KitSaasSharedCacheManagement::Base

    # Fetch from db
    #
    # * Author: Shlok
    # * Date: 05/03/2019
    # * Reviewed By:
    #
    # @return [Result::Base]
    #
    def fetch_from_db(chain_id)
      rsp = ::CurrencyConversionRate.new.fetch_price_points({chain_id: chain_id.first})
      data_to_cache = rsp.data
      success_with_data(data_to_cache)
    end

    #
    # * Author: Shlok
    # * Date: 05/03/2019
    # * Reviewed By:
    #
    # @return [MemcacheKey]
    #
    def memcache_key_object
      @m_k_o ||= MemcacheKey.new('ost_price_points.chain_specific')
    end

    # Fetch cache key
    #
    # * Author: Shlok
    # * Date: 05/03/2019
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
    # * Date: 05/03/2019
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
    # * Date: 05/03/2019
    # * Reviewed By:
    #
    # @return [Integer]
    #
    def get_cache_expiry
      memcache_key_object.expiry
    end

  end
end
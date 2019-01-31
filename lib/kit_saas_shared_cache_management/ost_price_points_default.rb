module KitSaasSharedCacheManagement

  class OstPricePointsDefault < KitSaasSharedCacheManagement::Base

    include Util::ResultHelper

    # Fetch from db
    #
    # * Author: Santosh
    # * Date: 06/04/2018
    # * Reviewed By:
    #
    # @return [Result::Base]
    #
    def fetch
      Memcache.get_set_memcached(get_kit_cache_key, get_cache_expiry) do
        fetch_from_db
      end
    end

    # Fetch from db
    #
    # * Author: Puneet
    # * Date: 19/01/2019
    # * Reviewed By:
    #
    # @return [Result::Base]
    #
    def fetch_from_db
      record = ::CurrencyConversionRate.where(["status = ? AND quote_currency = ?", 1, 1]).order('timestamp desc').first
      data_to_cache = {}
      if record
        data_to_cache[record.base_currency] = {}
        data_to_cache[record.base_currency][record.quote_currency] = record.conversion_rate.to_s
      end
      data_to_cache
    end

    # * Author: Ankit
    # * Date: 01/02/2018
    # * Reviewed By:
    #
    # @return [MemcacheKey]
    #
    def memcache_key_object
      @m_k_o ||= MemcacheKey.new('ost_price_points.default')
    end

    # Fetch cache key
    #
    # * Author: Puneet
    # * Date: 01/02/2018
    # * Reviewed By:
    #
    # @return [String]
    #
    def get_kit_cache_key
      memcache_key_object.key_template % {code_prefix: GlobalConstant::Cache.kit_key_prefix}
    end

    # Fetch cache key
    #
    # * Author: Puneet
    # * Date: 01/02/2018
    # * Reviewed By:
    #
    # @return [String]
    #
    def get_saas_cache_key
      memcache_key_object.key_template % {code_prefix: GlobalConstant::Cache.saas_key_prefix}
    end

    # Fetch cache expiry (in seconds)
    #
    # * Author: Puneet
    # * Date: 01/02/2018
    # * Reviewed By:
    #
    # @return [Integer]
    #
    def get_cache_expiry
      memcache_key_object.expiry
    end

    # clear cache
    #
    # * Author: Ankit
    # * Date: 19/01/2019
    # * Reviewed By:
    #
    # @return [Result::Base]
    #
    def clear
      Memcache.delete(get_kit_cache_key)
      Memcache.delete_from_all_instances(get_saas_cache_key)
    end

  end

end
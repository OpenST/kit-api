module CacheManagement

  # This cache is never cleared specifically. It clears only on the basis of TTL.
  class OstPricePointsDefault

    include Util::ResultHelper

    # Fetch from db
    #
    # * Author: Shlok
    # * Date: 05/03/2019
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
    # * Author: Shlok
    # * Date: 05/03/2019
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

    # * Author: Shlok
    # * Date: 05/03/2019
    # * Reviewed By:
    #
    # @return [MemcacheKey]
    #
    def memcache_key_object
      @m_k_o ||= MemcacheKey.new('ost_price_points_default.details')
    end

    # Fetch cache key
    #
    # * Author: Shlok
    # * Date: 05/03/2019
    # * Reviewed By:
    #
    # @return [String]
    #
    def get_kit_cache_key
      memcache_key_object.key_template % GlobalConstant::Cache.key_prefixes_template_vars.merge({code_prefix: GlobalConstant::Cache.kit_key_prefix})
    end

    # Fetch cache key
    #
    # * Author: Shlok
    # * Date: 05/03/2019
    # * Reviewed By:
    #
    # @return [String]
    #
    def get_saas_cache_key
      memcache_key_object.key_template % GlobalConstant::Cache.key_prefixes_template_vars.merge({code_prefix: GlobalConstant::Cache.saas_key_prefix})
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

    # Clear cache
    #
    # * Author: Shlok
    # * Date: 05/03/2019
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
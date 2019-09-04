module KitSaasSharedCacheManagement

  class LatestTransactions

    include Util::ResultHelper

    # Fetch from db
    #
    # * Author: Ankit
    # * Date: 21/08/2019
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
    # * Author: Ankit
    # * Date: 20/08/2019
    # * Reviewed By:
    #
    # @return [Result::Base]
    #
    def fetch_from_db
      rows = LatestTransaction.select('*').order('created_ts DESC').limit(30).all.to_a
      final_rsp = []
      rows.each do |row|
        final_rsp.push(row.formatted_cache_data)
      end
      data_to_cache = {
        transactions: final_rsp
      }
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
    def get_kit_cache_key
      memcache_key_object.key_template % GlobalConstant::Cache.key_prefixes_template_vars.merge({code_prefix: GlobalConstant::Cache.kit_key_prefix})
    end

    # Fetch saas cache key
    #
    # * Author: Ankit
    # * Date: 20/08/2019
    # * Reviewed By:
    #
    # @return [String]
    #
    def get_saas_cache_key
      memcache_key_object.key_template % GlobalConstant::Cache.key_prefixes_template_vars.merge({code_prefix: GlobalConstant::Cache.saas_key_prefix})
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

    # Clear cache
    #
    # * Author: Ankit
    # * Date: 21/08/2019
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
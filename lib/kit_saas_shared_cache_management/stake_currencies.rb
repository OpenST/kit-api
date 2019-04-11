module KitSaasSharedCacheManagement

  class StakeCurrencies < KitSaasSharedCacheManagement::Base

    # Fetch from db
    #
    # * Author: Santhosh
    # * Date: 11/04/2019
    # * Reviewed By:
    #
    # @return [Result::Base]
    #
    def fetch_from_db(ids)
      rsp = ::StakeCurrency.where(id: ids)
      data_to_cache = {}
      rsp.each do |stake_currency|
        data_to_cache[stake_currency.id] ||= []
        data_to_cache[stake_currency.id].push(stake_currency.formated_cache_data)
      end

      success_with_data(data_to_cache)
    end

    #
    # * Author: Santhosh
    # * Date: 11/04/2019
    # * Reviewed By:
    #
    # @return [MemcacheKey]
    #
    def memcache_key_object
      @m_k_o ||= MemcacheKey.new('stake_currency.details')
    end


    # Fetch cache key
    #
    # * Author: Santhosh
    # * Date: 11/04/2019
    # * Reviewed By:
    #
    # @return [String]
    #
    def get_kit_cache_key(id)
      generate_kit_cache_key @options.merge(id: id)
    end

    # Fetch saas cache key
    #
    # * Author: Santhosh
    # * Date: 11/04/2019
    # * Reviewed By:
    #
    # @return [String]
    #
    def get_saas_cache_key(id)
      generate_saas_cache_key @options.merge(id: id)
    end

    # Fetch cache expiry (in seconds)
    #
    # * Author: Santhosh
    # * Date: 11/04/2019
    # * Reviewed By:
    #
    # @return [Integer]
    #
    def get_cache_expiry
      memcache_key_object.expiry
    end

  end

end

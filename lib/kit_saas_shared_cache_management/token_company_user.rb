module KitSaasSharedCacheManagement

  class TokenCompanyUser < KitSaasSharedCacheManagement::Base

    # Fetch from db
    #
    # * Author: Shlok
    # * Date: /03/2019
    # * Reviewed By:
    #
    # @return [Result::Base]
    #
    def fetch_from_db(token_ids)
      rsp = ::TokenCompanyUser.new.fetch_all_uuids({token_ids:token_ids})
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
      @m_k_o ||= MemcacheKey.new('token_company_users.details')
    end

    # Fetch cache key
    #
    # * Author: Shlok
    # * Date: /03/2019
    # * Reviewed By:
    #
    # @return [String]
    #
    def get_kit_cache_key(token_id)
      generate_kit_cache_key @options.merge(token_id: token_id)
    end

    # Fetch saas cache key
    #
    # * Author: Shlok
    # * Date: /03/2019
    # * Reviewed By:
    #
    # @return [String]
    #
    def get_saas_cache_key(token_id)
      generate_saas_cache_key @options.merge(token_id: token_id)
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
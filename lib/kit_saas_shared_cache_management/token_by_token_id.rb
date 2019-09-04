module KitSaasSharedCacheManagement

  class TokenByTokenId < KitSaasSharedCacheManagement::Base
    # Fetch from db
    #
    # * Author: Ankit
    # * Date: 20/08/2019
    # * Reviewed By:
    #
    # @return [Result::Base]
    #
    def fetch_from_db(token_ids)
      tokens = ::Token.where(id: token_ids).all
      data_to_cache = {}
      tokens.each do |token|
        data_to_cache[token.id] = token.formatted_cache_data
      end
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
      @m_k_o ||= MemcacheKey.new('token_management.by_token_id')
    end

    # Fetch cache key
    #
    # * Author: Ankit
    # * Date: 20/08/2019
    # * Reviewed By:
    #
    # @return [String]
    #
    def get_kit_cache_key(token_id)
      generate_kit_cache_key @options.merge(token_id: token_id)
    end

    # Fetch saas cache key
    #
    # * Author: Ankit
    # * Date: 20/08/2019
    # * Reviewed By:
    #
    # @return [String]
    #
    def get_saas_cache_key(token_id)
      generate_saas_cache_key @options.merge(token_id: token_id)
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

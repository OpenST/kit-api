module KitSaasSharedCacheManagement

  class TokenDetails < KitSaasSharedCacheManagement::Base

    # Fetch from db
    #
    # * Author: Ankit
    # * Date: 19/01/2019
    # * Reviewed By:
    #
    # @return [Result::Base]
    #
    def fetch_from_db(client_ids)
      tokens = ::Token.where(client_id: client_ids).all
      data_to_cache = {}
      tokens.each do |token|
        data_to_cache[token.client_id] = token.formated_cache_data
      end
      success_with_data(data_to_cache)
    end

    #
    # * Author: Puneet
    # * Date: 06/12/2018
    # * Reviewed By:
    #
    # @return [MemcacheKey]
    #
    def memcache_key_object
      @m_k_o ||= MemcacheKey.new('token_management.details')
    end

    # Fetch cache key
    #
    # * Author: Puneet
    # * Date: 06/12/2018
    # * Reviewed By:
    #
    # @return [String]
    #
    def get_kit_cache_key(client_id)
      generate_kit_cache_key @options.merge(client_id: client_id)
    end

    # Fetch saas cache key
    #
    # * Author: Puneet
    # * Date: 06/12/2018
    # * Reviewed By:
    #
    # @return [String]
    #
    def get_saas_cache_key(client_id)
      generate_saas_cache_key @options.merge(client_id: client_id)
    end

    # Fetch cache expiry (in seconds)
    #
    # * Author: Puneet
    # * Date: 06/12/2018
    # * Reviewed By:
    #
    # @return [Integer]
    #
    def get_cache_expiry
      memcache_key_object.expiry
    end

  end

end
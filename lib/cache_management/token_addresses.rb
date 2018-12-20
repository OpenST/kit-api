module CacheManagement

  class TokenAddresses < CacheManagement::Base

    # Fetch from db
    #
    # * Author: Dhananjay
    # * Date: 20/12/2018
    # * Reviewed By:
    #
    # @return [Result::Base]
    #
    def fetch_from_db(token_id)
      tokens = ::TokenAddresses.where(token_id: token_id).all
      data_to_cache = {}
      tokens.each do |token|
        data_to_cache[token.token_id] = token.formated_cache_data
      end
      success_with_data(data_to_cache)
    end

    #
    # * Author: Dhananjay
    # * Date: 20/12/2018
    # * Reviewed By:
    #
    # @return [MemcacheKey]
    #
    def memcache_key_object
      @m_k_o ||= MemcacheKey.new('token_address.details')
    end

    # Fetch cache key
    #
    # * Author: Dhananjay
    # * Date: 20/12/2018
    # * Reviewed By:
    #
    # @return [String]
    #
    def get_cache_key(token_id)
      memcache_key_object.key_template % @options.merge(token_id: token_id)
    end

    # Fetch cache expiry (in seconds)
    #
    # * Author: Dhananjay
    # * Date: 20/12/2018
    # * Reviewed By:
    #
    # @return [Integer]
    #
    def get_cache_expiry
      memcache_key_object.expiry
    end

  end
end
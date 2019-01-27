module CacheManagement

  # This cache has list of domains which are allowed for Developer POC Program. SHOULD NOT BE SENT TO FE
  
  class ClientWhitelistedDomains

    include Util::ResultHelper

    # Fetch from db
    #
    # * Author: Puneet
    # * Date: 26/04/2018
    # * Reviewed By:
    #
    # @return [Result::Base]
    #
    def fetch

      Memcache.get_set_memcached(get_cache_key, get_cache_expiry) do
        {domains: ClientWhitelisting.where(kind: GlobalConstant::ClientWhitelisting.domain_kind).
            select(:identifier).all.collect(&:identifier)}
      end

    end

    # clear cache
    #
    # * Author: Puneet
    # * Date: 26/04/2018
    # * Reviewed By:
    #
    # @return [Result::Base]
    #
    def clear
      Memcache.delete(get_cache_key)
      success
    end

    private

    # Memcache Key Object
    #
    # * Author: Puneet
    # * Date: 26/04/2018
    # * Reviewed By:
    #
    # @return [MemcacheKey]
    #
    def memcache_key_object
      @m_k_o ||= MemcacheKey.new('client.whitelisted_domains')
    end

    # Fetch cache key
    #
    # * Author: Puneet
    # * Date: 26/04/2018
    # * Reviewed By:
    #
    # @return [String]
    #
    def get_cache_key
      memcache_key_object.key_template % {prefix: memcache_key_object.kit_key_prefix}
    end

    # Fetch cache expiry (in seconds)
    #
    # * Author: Puneet
    # * Date: 26/04/2018
    # * Reviewed By:
    #
    # @return [Integer]
    #
    def get_cache_expiry
      memcache_key_object.expiry
    end

  end

end
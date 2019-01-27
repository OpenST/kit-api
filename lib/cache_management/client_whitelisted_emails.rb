module CacheManagement

  # This cache has list of emails which are allowed for Developer POC Program. SHOULD NOT BE SENT TO FE
  class ClientWhitelistedEmails

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

      Memcache.get_set_memcached(get_cache_key, get_cache_expiry) do
        {emails: ClientWhitelisting.where(kind: GlobalConstant::ClientWhitelisting.email_kind).
            select(:identifier).all.collect(&:identifier)}
      end

    end

    # clear cache
    #
    # * Author: Santosh
    # * Date: 06/04/2018
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
    # * Author: Santosh
    # * Date: 06/04/2018
    # * Reviewed By:
    #
    # @return [MemcacheKey]
    #
    def memcache_key_object
      @m_k_o ||= MemcacheKey.new('client.whitelisted_emails')
    end

    # Fetch cache key
    #
    # * Author: Santosh
    # * Date: 06/04/2018
    # * Reviewed By:
    #
    # @return [String]
    #
    def get_cache_key
      memcache_key_object.key_template % {prefix: memcache_key_object.kit_key_prefix}
    end

    # Fetch cache expiry (in seconds)
    #
    # * Author: Santosh
    # * Date: 06/04/2018
    # * Reviewed By:
    #
    # @return [Integer]
    #
    def get_cache_expiry
      memcache_key_object.expiry
    end

  end

end
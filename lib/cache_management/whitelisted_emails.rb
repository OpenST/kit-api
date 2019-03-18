module CacheManagement

  # This cache has list of emails which are allowed for Developer POC Program. SHOULD NOT BE SENT TO FE
  class WhitelistedEmails

    include Util::ResultHelper

    # Fetch from db
    #
    # * Author: Puneet
    # * Date: 18/03/2019
    # * Reviewed By:
    #
    # @return [Result::Base]
    #
    def fetch

      data_to_cache = Memcache.get_set_memcached(get_cache_key, get_cache_expiry) do
        {emails: ManagerWhitelisting.where(
            kind: GlobalConstant::ManagerWhitelisting.email_kind
        ).select(:identifier).all.collect(&:identifier)}
      end

      success_with_data(data_to_cache)

    end

    # clear cache
    #
    # * Author: Puneet
    # * Date: 18/03/2019
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
    # * Date: 18/03/2019
    # * Reviewed By:
    #
    # @return [MemcacheKey]
    #
    def memcache_key_object
      @m_k_o ||= MemcacheKey.new('manager.whitelisted_emails')
    end

    # Fetch cache key
    #
    # * Author: Puneet
    # * Date: 18/03/2019
    # * Reviewed By:
    #
    # @return [String]
    #
    def get_cache_key
      options = {code_prefix: GlobalConstant::Cache.kit_key_prefix}
      memcache_key_object.key_template % options.merge(GlobalConstant::Cache.key_prefixes_template_vars)
    end

    # Fetch cache expiry (in seconds)
    #
    # * Author: Puneet
    # * Date: 18/03/2019
    # * Reviewed By:
    #
    # @return [Integer]
    #
    def get_cache_expiry
      memcache_key_object.expiry
    end

  end

end
module KitSaasSharedCacheManagement

  class ClientWhitelisting < KitSaasSharedCacheManagement::Base

    # Fetch from db
    #
    # * Author: Puneet
    # * Date: 28/01/2018
    # * Reviewed By:
    #
    # @return [Result::Base]
    #
    def fetch_from_db(client_ids)
      db_rows = ::ClientWhitelisting.where(client_id: client_ids).all
      data_to_cache = {}
      db_rows.each do |db_row|
        data_to_cache[db_row.client_id] = db_row.formated_cache_data
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
      @m_k_o ||= MemcacheKey.new('client.whitelisting')
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
      generate_kit_cache_key @options.merge(id: client_id)
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
      generate_saas_cache_key @options.merge(id: client_id)
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
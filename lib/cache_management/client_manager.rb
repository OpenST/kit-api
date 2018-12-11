module CacheManagement

  class ClientManager < CacheManagement::Base

    private

    # Fetch from db
    #
    # * Author: Puneet
    # * Date: 06/12/2018
    # * Reviewed By:
    #
    # @return [Result::Base]
    #
    def fetch_from_db(manager_ids)
      data_to_cache = ::ClientManager.where(
          manager_id: manager_ids,
          client_id: @options[:client_id]).inject({}
      ) do |client_managers_data, client_manager|
        client_managers_data[client_manager.manager_id] = client_manager.formated_cache_data
        client_managers_data
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
      @m_k_o ||= MemcacheKey.new('client_manager.details')
    end

    # Fetch cache key
    #
    # * Author: Puneet
    # * Date: 06/12/2018
    # * Reviewed By:
    #
    # @return [String]
    #
    def get_cache_key(manager_id)
      memcache_key_object.key_template % @options.merge(manager_id: manager_id, client_id: @options[:client_id])
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
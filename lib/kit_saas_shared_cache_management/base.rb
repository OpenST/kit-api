module KitSaasSharedCacheManagement

  class Base

    include Util::ResultHelper

    # Initialize
    #
    # * Author: Puneet
    # * Date: 06/12/2018
    # * Reviewed By:
    #
    # @param [Array] ids (mandatory) - ids which would form cache keys
    # @param [Hash] options (optional) - optional params which might be needed in forming cache key
    #
    # @return [CacheManagement::Base]
    #
    def initialize(ids, options = {})

      @ids = ids
      @options = options

      @id_to_cache_key_map = {}

    end

    # Clear cache
    #
    # * Author: Puneet
    # * Date: 06/12/2018
    # * Reviewed By:
    #
    def clear

      set_id_to_cache_key_map

      @id_to_cache_key_map.each do |_, keys|
        Memcache.delete(keys[:kit])
        Memcache.delete_from_all_instances(keys[:saas])
      end

      nil

    end

    # Fetch from cache and for cache misses call fetch_from_db
    #
    # * Author: Puneet
    # * Date: 06/12/2018
    # * Reviewed By:
    #
    # @return [Hash]
    #
    def fetch

      set_id_to_cache_key_map

      cache_keys_to_fetch = []
      @id_to_cache_key_map.each do |_, keys|
        cache_keys_to_fetch.push(keys[:kit])
      end

      data_from_cache = Memcache.read_multi(cache_keys_to_fetch)

      ids_for_cache_miss = []
      @ids.each do |id|
        ids_for_cache_miss << id if data_from_cache[@id_to_cache_key_map[id][:kit]].nil?
      end

      if ids_for_cache_miss.any?

        fetch_data_rsp = fetch_from_db(ids_for_cache_miss)

        data_to_set = fetch_data_rsp.data || {}

        # to ensure we do not always query DB for invalid ids being cached, we would set {} in cache against such ids
        @ids.each do |id|
          data_to_set[id] = {} if data_from_cache[@id_to_cache_key_map[id][:kit]].nil? && data_to_set[id].nil?
        end

        set_cache(data_to_set) if fetch_data_rsp.success?

      end

      @ids.inject({}) do |data, id|
        data[id] = data_from_cache[@id_to_cache_key_map[id][:kit]] || data_to_set[id]
        data
      end

    end

    private

    # Fetch from db
    #
    # * Author: Puneet
    # * Date: 06/12/2018
    # * Reviewed By:
    #
    # @return [Result::Base]
    #
    def fetch_from_db(cache_miss_ids)
      fail 'sub class to implement'
    end

    # Fetch cache key in Kit
    #
    # * Author: Puneet
    # * Date: 06/12/2018
    # * Reviewed By:
    #
    # @return [String]
    #
    def get_kit_cache_key(id)
      fail 'sub class to implement'
    end

    # Fetch cache key in Saas (only used to flush for Saas)
    #
    # * Author: Puneet
    # * Date: 06/12/2018
    # * Reviewed By:
    #
    # @return [String]
    #
    def get_saas_cache_key(id)
      fail 'sub class to implement'
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
      fail 'sub class to implement'
    end

    # Set Id to Cache Key Map
    #
    # * Author: Puneet
    # * Date: 06/12/2018
    # * Reviewed By:
    #
    def set_id_to_cache_key_map
      @ids.each do |id|
        @id_to_cache_key_map[id] = {
          kit: get_kit_cache_key(id),
          saas: get_saas_cache_key(id)
        }
      end
    end

    # set cache (in Kit's key) using data provided (data is indexed by id)
    #
    # * Author: Puneet
    # * Date: 06/12/2018
    # * Reviewed By:
    #
    def set_cache(cache_data)
      cache_data.each do |id, data|
        Memcache.write(@id_to_cache_key_map[id][:kit], data, get_cache_expiry)
      end
    end

  end

end
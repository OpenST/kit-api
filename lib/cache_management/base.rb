module CacheManagement

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

      @id_to_cache_key_map.each do |_, key|
        Memcache.delete(key)
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

      data_from_cache = Memcache.read_multi(@id_to_cache_key_map.values)

      ids_for_cache_miss = []
      @ids.each do |id|
        ids_for_cache_miss << id if data_from_cache[@id_to_cache_key_map[id]].nil?
      end

      if ids_for_cache_miss.any?

        fetch_data_rsp = fetch_from_db(ids_for_cache_miss)

        data_to_set = fetch_data_rsp.data || {}

        # to ensure we do not always query DB for invalid ids being cached, we would set {} in cache against such ids
        @ids.each do |id|
          data_to_set[id] = {} if data_from_cache[@id_to_cache_key_map[id]].nil? && data_to_set[id].nil?
        end

        set_cache(data_to_set) if fetch_data_rsp.success?

      end

      @ids.inject({}) do |data, id|
        data[id] = data_from_cache[@id_to_cache_key_map[id]] || data_to_set[id]
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

    # Fetch cache key
    #
    # * Author: Puneet
    # * Date: 06/12/2018
    # * Reviewed By:
    #
    # @return [String]
    #
    def get_cache_key(id)
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
        @id_to_cache_key_map[id] = get_cache_key(id)
      end
    end

    # set cache using data provided (data is indexed by id)
    #
    # * Author: Puneet
    # * Date: 06/12/2018
    # * Reviewed By:
    #
    def set_cache(cache_data)
      cache_data.each do |id, data|
        Memcache.write(@id_to_cache_key_map[id], data, get_cache_expiry)
      end
    end

  end

end
module KitSaasSharedCacheManagement

  class Workflow < KitSaasSharedCacheManagement::Base

    # Fetch from db
    #
    # * Author: Ankit
    # * Date: 19/01/2019
    # * Reviewed By:
    #
    # @return [Result::Base]
    #
    def fetch_from_db(ids)
      rsp = ::Workflow.where(id: ids).all
      data_to_cache = {}
      rsp.each do |workflow_row_data|
        data_to_cache[workflow_row_data.id] = workflow_row_data
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
      @m_k_o ||= MemcacheKey.new('workflow.default')
    end

    # Fetch cache key
    #
    # * Author: Puneet
    # * Date: 06/12/2018
    # * Reviewed By:
    #
    # @return [String]
    #
    def get_kit_cache_key(workflow_id)
      generate_kit_cache_key @options.merge(id: workflow_id)
    end

    # Fetch saas cache key
    #
    # * Author: Puneet
    # * Date: 06/12/2018
    # * Reviewed By:
    #
    # @return [String]
    #
    def get_saas_cache_key(workflow_id)
      generate_saas_cache_key @options.merge(id: workflow_id)
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

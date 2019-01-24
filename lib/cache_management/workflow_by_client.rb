module CacheManagement

  class WorkflowByClient < CacheManagement::Base

    # Fetch from db
    #
    # * Author: Ankit
    # * Date: 19/01/2019
    # * Reviewed By:
    #
    # @return [Result::Base]
    #
    def fetch_from_db(client_ids)
      rsp = ::Workflow.where(client_id: client_ids).order('id DESC')
      data_to_cache = {}
      rsp.each do |workflow_row_data|
        data_to_cache[workflow_row_data.client_id] ||= []
        data_to_cache[workflow_row_data.client_id].push(workflow_row_data)
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
      @m_k_o ||= MemcacheKey.new('workflow.by_client')
    end

    # Fetch cache key
    #
    # * Author: Puneet
    # * Date: 06/12/2018
    # * Reviewed By:
    #
    # @return [String]
    #
    def get_cache_key(client_id)
      memcache_key_object.key_template % @options.merge(client_id: client_id)
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

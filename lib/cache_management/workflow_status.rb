module CacheManagement
  class WorkflowStatus < CacheManagement::Base

    include Util::ResultHelper

    #
    # Fetch from db
    #
    # * Author: Ankit
    # * Date: 15/01/2019
    # * Reviewed By:
    #
    # @return [Result::Base]
    #
    def fetch_from_db(cache_miss_ids)

      workflow_steps = ::WorkflowSteps.new({workflow_ids:cache_miss_ids}).perform

      data_to_cache = workflow_steps.data
      success_with_data(data_to_cache)
    end

    private

    # Memcache Key Object
    #
    # * Author: Ankit
    # * Date: 15/01/2019
    # * Reviewed By:
    #
    # @return [MemcacheKey]
    #
    def memcache_key_object
      @m_k_o ||= MemcacheKey.new('workflow_status.default')
    end

    # Fetch cache key
    #
    # * Author: Ankit
    # * Date: 15/01/2019
    # * Reviewed By:
    #
    # @return [String]
    #
    def get_cache_key(id)
      memcache_key_object.key_template % @options.merge(workflow_id: id)
    end

    # Fetch cache expiry (in seconds)
    #
    # * Author: Ankit
    # * Date: 15/01/2019
    # * Reviewed By:
    #
    # @return [Integer]
    #
    def get_cache_expiry
      memcache_key_object.expiry
    end

  end
end
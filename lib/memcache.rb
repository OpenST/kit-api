class Memcache

  class << self

    def get_ttl(ttl)
      (ttl.to_i == 0  || ttl > GlobalConstant::Cache.default_ttl) ? GlobalConstant::Cache.default_ttl : ttl.to_i
    end

    def write(key, value, ttl = 0, marshaling = true)
      Rails.cache.write(key, value, {expires_in: get_ttl(ttl), raw: !marshaling})
      nil
    rescue => exc
      Rails.logger.error { "MEMCACHE-ERROR: write: K: #{key}. M: #{exc.message}, I: #{exc.inspect}" }
      nil
    end

    def read(key, _marshaling = true)
      Rails.cache.read(key)
    rescue => exc
      Rails.logger.error { "MEMCACHE-ERROR: read: K: #{key}. M: #{exc.message}, I: #{exc.inspect}" }
      nil
    end

    def read_multi(keys, _marshaling = true)
      t_start = Time.now.to_f
      ret = Rails.cache.read_multi(*keys)
      Rails.logger.debug "Memcache multi get took #{Time.now.to_f - t_start} s"
      return ret
    rescue => exc
      Rails.logger.error { "MEMCACHE-ERROR: read_multi: K: #{keys}. M: #{exc.message}, I: #{exc.inspect}" }
      return {}
    end

    def get_set_memcached(key, ttl = 0, marshaling = true)
      raise 'block not given to get_set_memcached' unless block_given?

      Rails.cache.fetch(key, {expires_in: get_ttl(ttl), raw: !marshaling}) do
        yield
      end

    rescue => exc
      Rails.logger.error { "MEMCACHE-ERROR: fetch: K: #{key.inspect}. M: #{exc.message}, I: #{exc.inspect}" }
      nil
    end

    def get_set_memcached_multi(keys, ttl = 0, marshaling = true)

      raise 'block not given to get_set_memcached' unless block_given?

      Rails.cache.fetch_multi(*keys, {expires_in: get_ttl(ttl), raw: !marshaling}) do
        yield
      end

    rescue => exc
      Rails.logger.error { "MEMCACHE-ERROR: fetch_multi: K: #{keys.inspect}. M: #{exc.message}, I: #{exc.inspect}" }
      nil
    end

    def exist?(key, options = nil)
      Rails.cache.exist?(key, options)
    rescue => exc
      Rails.logger.error { "MEMCACHE-ERROR: exists?: K: #{key.inspect}. M: #{exc.message}, I: #{exc.inspect}" }
      nil
    end

    def delete(key, options = nil)
      Rails.cache.delete(key, options)
    rescue => exc
      Rails.logger.error { "MEMCACHE-ERROR: delete: K: #{key.inspect}. M: #{exc.message}, I: #{exc.inspect}" }
      nil
    end

    def increment(key, inc_value = 1, expires_in = nil, initial = nil)
      puts "Rails.cache.increment(#{key}, #{inc_value}, {expires_in: #{get_ttl(expires_in)}, initial: #{initial}, raw: false})"
      return Rails.cache.increment(key, inc_value, {expires_in: get_ttl(expires_in), initial: initial, raw: false})
    rescue => exc
      Rails.logger.error { "MEMCACHE-ERROR: increment: K: #{key}. M: #{exc.message}, I: #{exc.inspect}" }
      return nil
    end

    def decrement(key, value = 1, expires_in = nil, initial = nil)
      puts "Rails.cache.decrement(#{key}, #{value}, {expires_in: #{get_ttl(expires_in)}, initial: #{initial}, raw: false})"
      return Rails.cache.decrement(key, value, {expires_in: get_ttl(expires_in), initial: initial, raw: false})
    rescue => exc
      Rails.logger.error { "MEMCACHE-ERROR: decrement: K: #{key}. M: #{exc.message}, I: #{exc.inspect}" }
      return nil
    end

    def delete_from_all_instances(key)
      GlobalConstant::Cache.memcached_instances.each do |instance_url|
        dc = Dalli::Client.new(instance_url, GlobalConstant::Cache.memcached_config)
        Rails.logger.debug "MEMCACHE-DEBUG: delete #{key} from #{instance_url}"
        dc.delete(key)
      end
    end

  end

end

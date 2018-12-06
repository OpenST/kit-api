# frozen_string_literal: true
module GlobalConstant

  class Cache

    def self.memcached_instances
      @memcached_instances = Base.memcache_config['instances'].to_s.split(',').map(&:strip)
    end

    def self.default_ttl
      24.hours.to_i
    end

    def self.keys_config_file
      "#{Rails.root}/config/memcache_keys.yml"
    end

  end

end
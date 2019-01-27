# frozen_string_literal: true
module GlobalConstant

  class Cache

    def self.memcached_instances
      @memcached_instances = Base.memcache_config['instances'].to_s.split(',').map(&:strip)
    end

    def self.memcached_config
      @m_c ||= {
        expires_in: 1.day,
        compress: false,
        down_retry_delay: 5,
        socket_timeout: 1
      }
    end

    def self.default_ttl
      24.hours.to_i
    end

    def self.keys_config_file
      "#{Rails.root}/config/memcache_keys.yml"
    end

  end

end
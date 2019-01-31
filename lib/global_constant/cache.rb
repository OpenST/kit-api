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

    def self.key_prefixes_template_vars
      @k_p_t ||= begin
        {
          kit_saas: "#{GlobalConstant::Base.environment_name_short}_KIT_SAAS",
          kit: "#{GlobalConstant::Base.environment_name_short}_KIT",
          saas: "#{GlobalConstant::Base.environment_name_short}_SAAS",
          kit_subenv: "#{GlobalConstant::Base.environment_name_short}_#{GlobalConstant::Base.sub_env_short}_KIT",
          saas_subenv: "#{GlobalConstant::Base.environment_name_short}_#{GlobalConstant::Base.sub_env_short}_SAAS",
          kit_saas_subenv: "#{GlobalConstant::Base.environment_name_short}_#{GlobalConstant::Base.sub_env_short}_KIT_SAAS",
        }
      end
    end

    def self.key_prefixes
      @k_c ||= begin
        buffer = {}
        memcache_config = YAML.load_file(keys_config_file)
        memcache_config['prefixes'].each do |k, v|
          buffer[k] = "#{v['prefix'] % key_prefixes_template_vars}"
        end
        buffer
      end
    end

    def self.kit_key_prefix
      'K'
    end

    def self.saas_key_prefix
      'S'
    end

  end

end
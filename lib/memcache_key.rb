class MemcacheKey

  attr_reader :key_template, :saas_shared_key_prefix ,:kit_key_prefix, :expiry, :shared_with_saas

  def initialize(entity)
    buffer = self.class.config_for_entity(entity)
    @key_template = buffer[:key_template]
    @kit_key_prefix = buffer[:kit_key_prefix]
    @saas_shared_key_prefix = buffer[:saas_shared_key_prefix]
    @expiry = buffer[:expiry]
    @shared_with_saas = buffer[:shared_with_saas] == 1
  end

  private

  def self.config_for_entity(entity)
    config_for_all_keys[entity.to_sym]
  end

  def self.config_for_all_keys
    # Cache marked as "shared_with_saas" are shared between company api and saas
    # Cache keys prefixed with shared environment can be flushed from company api or saas.
    @memcache_config ||= begin
      memcache_config = YAML.load_file(GlobalConstant::Cache.keys_config_file)
      memcache_config.inject({}) do |formatted_memcache_config, (group, group_config)|
        group_config.each do |entity, config|
          formatted_memcache_config["#{group}.#{entity}".to_sym] = {
              key_template: "%{prefix}_#{config['key_template']}",
              kit_key_prefix: kit_key_prefix(config['shared_with_saas'] == 1),
              saas_shared_key_prefix: saas_shared_key_prefix,
              expiry: config['expiry_in_seconds'].to_i,
              shared_with_saas: config['shared_with_saas']
          }
        end
        formatted_memcache_config
      end
    end
  end

  def self.kit_key_prefix(shared_cache)
    buffer = shared_cache ? 'kit_shared' : 'kit'
    "#{buffer}_#{GlobalConstant::Base.environment_name_short}_#{GlobalConstant::Base.sub_env_short}"
  end

  def self.saas_shared_key_prefix
    "sa_shared_#{GlobalConstant::Base.environment_name_short}_#{GlobalConstant::Base.sub_env_short}"
  end

end
# frozen_string_literal: true
module GlobalConstant

  class Base

    def self.environment_name
      Rails.env
    end

    def self.sub_environment_name
      @sub_env ||= fetch_config.fetch('sub_env')
    end

    def self.env_identifier
      @env_identifier ||= fetch_config.fetch('env_identifier', '')
    end

    def self.main_sub_environment?
      sub_environment_name =='main'
    end

    def self.sandbox_sub_environment?
      sub_environment_name =='sandbox'
    end

    def self.environment_name_short
      Rails.env[0,2]
    end

    def self.sub_env_short
      sub_environment_name[0,2]
    end

    def self.aws
      @aws ||= fetch_config.fetch('aws', {}).with_indifferent_access
    end

    def self.kms
      @kms ||= fetch_config.fetch('kms', {}).with_indifferent_access
    end

    def self.secret_encryptor
      @secret_encryptor_key ||= fetch_config.fetch('secret_encryptor', {}).with_indifferent_access
    end

    def self.recaptcha
      @recaptcha ||= fetch_config.fetch('recaptcha', {}).with_indifferent_access
    end

    def self.memcache_config
      @memcache_config ||= fetch_config.fetch('memcached', {}).with_indifferent_access
    end

    def self.pepo_campaigns_config
      @pepo_campaigns_config ||= fetch_config.fetch('pepo_campaigns', {}).with_indifferent_access
    end

    def self.basic_auth_config
      @basic_auth_config ||= fetch_config.fetch('basic_auth', {}).with_indifferent_access
    end

    def self.company_web_config
      @company_web_config ||= fetch_config.fetch('company_web', {}).with_indifferent_access
    end

    private

    def self.fetch_config
      @f_config ||= begin
        template = ERB.new File.new("#{Rails.root}/config/constants.yml").read
        YAML.load(template.result(binding)).fetch('constants', {}) || {}
      end
    end
  end

end
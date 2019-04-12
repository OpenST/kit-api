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

    def self.cookie_domain
      @cookie_domain ||= fetch_config.fetch('cookie_domain')
    end

    def self.support_email
      @support_email ||= fetch_config.fetch('support_email', '')
    end

    def self.activate_test_economy_auth_token
      @ateat ||= fetch_config.fetch('activate_test_economy_auth_token', '')
    end

    def self.main_sub_environment?
      sub_environment_name == GlobalConstant::Environment.main_sub_environment
    end

    def self.sandbox_sub_environment?
      sub_environment_name == GlobalConstant::Environment.sandbox_sub_environment
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

    def self.s3
      @s3 ||= fetch_config.fetch('s3', {}).with_indifferent_access
    end

    def self.kms
      @kms ||= fetch_config.fetch('kms', {}).with_indifferent_access
    end

    def self.secret_encryptor
      @secret_encryptor_key ||= fetch_config.fetch('secret_encryptor', {}).with_indifferent_access
    end

    def self.recaptcha_config
      @recaptcha ||= fetch_config.fetch('recaptcha', {}).with_indifferent_access
    end

    def self.memcache_config
      @memcache_config ||= fetch_config.fetch('memcached', {}).with_indifferent_access
    end

    def self.pepo_campaigns_config
      @pepo_campaigns_config ||= fetch_config.fetch('pepo_campaigns', {}).with_indifferent_access
    end

    def self.admin_basic_auth_config
      @admin_basic_auth_config ||= fetch_config.fetch('admin_basic_auth', {}).with_indifferent_access
    end

    def self.company_web_config
      @company_web_config ||= fetch_config.fetch('company_web', {}).with_indifferent_access
    end

    def self.redis_config
      @redis_config ||= fetch_config.fetch('redis', {})
    end

    def self.saas_api
      @saas_api ||= fetch_config.fetch('saas_api', {}).with_indifferent_access
    end

    def self.demo_mappy_server
      @demo_mappy_server ||= fetch_config.fetch('demo_mappy_server', {}).with_indifferent_access
    end

    def self.grant_timeout
      86400 #24 hours
    end
    
    def self.usage_report_recipients_config
      @usage_report_recipients ||= fetch_config.fetch('usage_report_recipients', {}).with_indifferent_access
    end

    def self.current_api_version
      'v2'
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
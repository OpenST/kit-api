# frozen_string_literal: true
module GlobalConstant

  class Environment

    def self.main_sub_environment
      'main'
    end

    def self.sandbox_sub_environment
      'sandbox'
    end

    def self.mainnet_url_prefix
      'mainnet'
    end

    def self.testnet_url_prefix
      'testnet'
    end

    def self.production_environment
      'production'
    end

    def self.url_prefix
      GlobalConstant::Base.main_sub_environment? ? mainnet_url_prefix : testnet_url_prefix
    end

    def self.is_development_env?
      Rails.env.development?
    end

    def self.subenv_communication_secret
      @subenv_secret_key ||= ENV['KA_SUBENV_COMMUNICATION_SERVER_SECRET_KEY']
    end

  end

end
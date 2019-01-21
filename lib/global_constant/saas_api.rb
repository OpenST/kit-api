# frozen_string_literal: true
module GlobalConstant

  class SaasApi

    def self.base_url
      GlobalConstant::Base.saas_api[:endpoint]
    end

    def self.secret_key
      GlobalConstant::Base.saas_api[:secret_key]
    end


    def self. fetch_client_stats
      'internal/client/fetch-stats'
    end

    def self.associate_address
      'internal/signer/verify'
    end

    def self.fetch_token_details
      'internal/token/details'
    end

    def self.token_deploy
      "#{GlobalConstant::Environment.url_prefix}/api/internal/token/deploy"
    end

    def self.mint
      "#{GlobalConstant::Environment.url_prefix}/api/internal/token/mint"
    end

  end

end

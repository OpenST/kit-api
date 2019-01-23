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
      "#{GlobalConstant::Environment.url_prefix}/internal/client/fetch-stats"
    end

    def self.associate_address
      "#{GlobalConstant::Environment.url_prefix}/internal/signer/verify"
    end

    def self.fetch_token_details
      "#{GlobalConstant::Environment.url_prefix}/internal/token/details"
    end

    def self.token_deploy
      "#{GlobalConstant::Environment.url_prefix}/internal/token/deploy"
    end

    def self.mint
      "#{GlobalConstant::Environment.url_prefix}/internal/token/mint"
    end

  end

end

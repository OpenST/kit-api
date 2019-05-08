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

    def self.start_mint
      "#{GlobalConstant::Environment.url_prefix}/internal/token/mint"
    end

    def self.mint_details
      "#{GlobalConstant::Environment.url_prefix}/internal/token/mint-details"
    end

    def self.get_gateway_composer
      "#{GlobalConstant::Environment.url_prefix}/internal/contracts/gateway-composer"
    end

    def self.grant_eth_stake_currency
      "#{GlobalConstant::Environment.url_prefix}/internal/token/mint/grant"
    end

    def self.get_dashboard
      "#{GlobalConstant::Environment.url_prefix}/internal/token/get-dashboard"
    end

    def self.get_user_detail
      "#{GlobalConstant::Environment.url_prefix}/internal/user/get"
    end

    def self.api_endpoint_for_current_version
      "#{GlobalConstant::SaasApi.base_url}/#{GlobalConstant::Environment.url_prefix}/#{GlobalConstant::Base.current_api_version}/"
    end

  end

end

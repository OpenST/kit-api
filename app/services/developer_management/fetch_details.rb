module DeveloperManagement

  class FetchDetails < ServicesBase

    # Initialize
    #
    # * Author: Ankit
    # * Date: 04/02/2019
    # * Reviewed By: Sunil
    #
    # @params [Integer] client_id (mandatory) - Client Id
    # @params [Hash] client_manager (mandatory) - Client Manager
    #
    # @return [DeveloperManagement::FetchDetails]
    #
    def initialize(params)

      super

      @client_id = @params[:client_id]
      @client_manager = @params[:client_manager]

      @token = nil
      @price_points = nil
      @sub_env_payload_data = nil
      @api_response_data = {}

    end

    # Perform
    #
    # * Author: Ankit
    # * Date: 04/02/2019
    # * Reviewed By: Sunil
    #
    # @return [Result::Base]
    #
    def perform

      handle_errors_and_exceptions do

        r = validate_and_sanitize
        return r unless r.success?

        r = fetch_token_details
        return r unless r.success?

        r = fetch_sub_env_payloads
        return r unless r.success?

        r = fetch_addresses
        return r unless r.success?

        @api_response_data = {
          token: @token,
          client_manager: @client_manager,
          sub_env_payloads: @sub_env_payload_data,
          developer_page_addresses: @addresses
        }

        success_with_data(@api_response_data)

      end
    end

    # Validate and sanitize
    #
    # * Author: Shlok
    # * Date: 14/09/2018
    # * Reviewed By: Sunil
    #
    # @return [Result::Base]
    #
    def validate_and_sanitize

      r = validate
      return r unless r.success?

      success

    end

    # Fetch token details
    #
    # * Author: Ankit
    # * Date: 04/02/2019
    # * Reviewed By: Sunil
    #
    # @return [Result::Base]
    #
    def fetch_token_details
      token = KitSaasSharedCacheManagement::TokenDetails.new([@client_id]).fetch[@client_id] || {}

      # Take user to token setup if not yet setup
      if token.blank? || token[:status] == GlobalConstant::ClientToken.not_deployed
        @go_to = GlobalConstant::GoTo.token_setup
        return error_with_go_to(
          'a_s_dm_fd_1',
          'data_validation_failed',
          @go_to)
      end

      @token = token
      success
    end

    # fetch the sub env response data entity
    #
    # * Author: Ankit
    # * Date: 04/02/2019
    # * Reviewed By: Sunil
    #
    # @return [Result::Base]
    #
    def fetch_sub_env_payloads
      r = SubEnvPayload.new({client_id:@client_id}).perform
      return r unless r.success?

      @sub_env_payload_data = r.data[:sub_env_payloads]

      success
    end

    # Fetch the token addresses
    #
    # * Author: Shlok
    # * Date: 04/03/2019
    # * Reviewed By:
    #
    # @return [Result::Base]
    #
    def fetch_addresses
      token_id = @token[:id]

      @addresses = {}

      token_addresses_data = KitSaasSharedCacheManagement::TokenAddresses.new([token_id]).fetch || {}
      if token_addresses_data[token_id][GlobalConstant::TokenAddresses.utility_branded_token_contract].nil?
        return success
      else
        aux_chain_id = token_addresses_data[token_id][GlobalConstant::TokenAddresses.utility_branded_token_contract][:deployed_chain_id]
      end

      @addresses['token_holder_address'] = token_addresses_data[token_id][GlobalConstant::TokenAddresses.token_holder_master_copy_contract][:address] || ""
      @addresses['utility_branded_token_contract'] = token_addresses_data[token_id][GlobalConstant::TokenAddresses.utility_branded_token_contract][:address] || ""
      @addresses['branded_token_contract'] = token_addresses_data[token_id][GlobalConstant::TokenAddresses.branded_token_contract][:address] || ""

      chain_addresses_data = KitSaasSharedCacheManagement::ChainAddresses.new([aux_chain_id]).fetch || {}

      @addresses['erc20_contract_address'] = chain_addresses_data[aux_chain_id][GlobalConstant::ChainAddresses.st_prime_contract_kind][:address] || ""

      company_user_ids = KitSaasSharedCacheManagement::TokenCompanyUser.new([token_id]).fetch || {}

      @addresses['company_user_id'] = company_user_ids[token_id].first || ""

      staker_whitelisted_addresses = KitSaasSharedCacheManagement::StakerWhitelistedAddress.new([token_id]).fetch || {}

      @addresses['gateway_composer_address'] = staker_whitelisted_addresses[token_id][:gateway_composer_address] || ""

      success
    end

  end
end
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
    # @params [Object] manager(mandatory) - manager
    # @params [Integer] show_keys_enable_flag(optional) - show keys enable flag
    # @params [Integer] email_already_sent_flag(optional) - email already sent flag
    #
    # @return [DeveloperManagement::FetchDetails]
    #
    def initialize(params)

      super

      @client_id = @params[:client_id]
      @client_manager = @params[:client_manager]
      @manager = @params[:manager]

      @show_keys_enable_flag = @params[:show_keys_enable_flag]
      @email_already_sent_flag = @params[:email_already_sent_flag]

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

        r = fetch_stake_currency_details
        return r unless r.success?

        @api_response_data = {
          token: @token,
          stake_currencies: @stake_currencies,
          client_manager: @client_manager,
          manager: @manager,
          sub_env_payloads: @sub_env_payload_data,
          developer_page_addresses: @addresses,
          email_already_sent_flag: @email_already_sent_flag
        }

        #if secure data access cookie is valid, sent api_keys in response
        if @show_keys_enable_flag == 1
          r = fetch_api_credentials
          return r unless r.success?

          @api_response_data['api_keys'] = @api_keys

          r = fetch_webhook_secret
          return r unless r.success?

          @api_response_data['webhook_secrets'] = @webhook_secrets_data

        end

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

      token_resp = Util::EntityHelper.fetch_and_validate_token(@client_id, 'a_s_dm_fd')

      # Take user to token setup if not yet setup
      unless token_resp.success? || token_resp.data[:status] == GlobalConstant::ClientToken.not_deployed
        @go_to = GlobalConstant::GoTo.token_setup
        return error_with_go_to(
          'a_s_dm_fd_1',
          'data_validation_failed',
          @go_to)
      end

      @token = token_resp.data
      
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

      # Fetch token addresses.
      token_addresses_data = KitSaasSharedCacheManagement::TokenAddresses.new([token_id]).fetch || {}
      token_addresses = token_addresses_data[token_id]

      if token_addresses[GlobalConstant::TokenAddresses.owner_address_kind].nil?
        return success
      end
      @addresses['account_owner_address'] = token_addresses[GlobalConstant::TokenAddresses.owner_address_kind][:address]


      if token_addresses[GlobalConstant::TokenAddresses.branded_token_contract].nil?
        return success
      end
      @addresses['branded_token_contract'] = token_addresses[GlobalConstant::TokenAddresses.branded_token_contract][:address]


      if token_addresses[GlobalConstant::TokenAddresses.utility_branded_token_contract].nil?
        return success
      end
      @addresses['utility_branded_token_contract'] = token_addresses[GlobalConstant::TokenAddresses.utility_branded_token_contract][:address]
      aux_chain_id = token_addresses[GlobalConstant::TokenAddresses.utility_branded_token_contract][:deployed_chain_id]

      @token[:ubt_address] = @addresses['utility_branded_token_contract'] #This is needed as we are sending ubt address in token entity
      @token[:aux_chain_id] = aux_chain_id

      # Fetch company user uuid.
      company_user_ids = KitSaasSharedCacheManagement::TokenCompanyUser.new([token_id]).fetch || {}
      @addresses['company_user_id'] = company_user_ids[token_id].first
      @company_uuid = @addresses['company_user_id']

      # Fetch company token holder
      fetch_company_token_holder

      # Fetch gateway composer address.
      staker_whitelisted_addresses = KitSaasSharedCacheManagement::StakerWhitelistedAddress.new([token_id]).fetch || {}
      @addresses['gateway_composer_address'] = staker_whitelisted_addresses[token_id][:gateway_composer_address]

      success
    end

    # Fetch stake currency details.
    #
    # * Author: Anagha
    # * Date: 06/05/2019
    # * Reviewed By:
    #
    # @return [Result::Base]
    #
    def fetch_stake_currency_details

      @stake_currencies = Util::EntityHelper.fetch_stake_currency_details(@token[:stake_currency_id]).data

      @addresses['erc20_contract_address'] = @stake_currencies[@token[:stake_currency_symbol]][:contract_address]

      success

    end

    # Fetch company token holder address
    #
    # * Author: Santhosh
    # * Date: 08/05/2019
    # * Reviewed By:
    #
    # @return [Result::Base]
    #
    def fetch_company_token_holder
      params = { user_id: @company_uuid, client_id: @client_id }

      saas_response = SaasApi::User::Get.new.perform(params)
      user_data = saas_response.data

      @addresses['token_holder_address'] = user_data['user']['tokenHolderAddress'] if user_data['user']

      success
    end

    # Fetch existing api credentials
    #
    # * Author: Dhananjay
    # * Date: 03/06/2019
    # * Reviewed By:
    #
    # @return [Result::Base]
    #
    def fetch_api_credentials

      api_credentials = KitSaasSharedCacheManagement::ApiCredentials.new([@client_id]).fetch[@client_id]
      if api_credentials.length == 0
        return error_with_data(
          'a_s_dm_fd_2',
          'something_went_wrong',
          GlobalConstant::ErrorAction.default,
          @client_id
        )
      end

      @api_keys = api_credentials

      success
    end

    # Fetch existing api credentials
    #
    # * Author: Alpesh
    # * Date: 07/06/2019
    # * Reviewed By:
    #
    # @return [Result::Base]
    #
    def fetch_webhook_secret

      webhook_secrets = KitSaasSharedCacheManagement::WebhookSecret.new([@client_id]).fetch[@client_id]
      if webhook_secrets.blank?
        return error_with_data(
          's_cm_ws_f_1',
          'something_went_wrong',
          GlobalConstant::ErrorAction.default,
          @client_id
        )
      end

      @webhook_secrets_data = webhook_secrets

      success
    end

  end
end
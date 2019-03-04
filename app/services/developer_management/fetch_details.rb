module DeveloperManagement
  class FetchDetails < ServicesBase

    # Initialize
    #
    # * Author: Ankit
    # * Date: 04/02/2019
    # * Reviewed By:
    #
    # @params [Integer] client_id (mandatory) - Client Id
    #
    # @return [DeveloperManagement::FetchDetails]
    #
    def initialize(params)

      super

      @api_response_data = {}

      @client_id = params[:client_id]
      @client_manager = params[:client_manager]

    end

    # Perform
    #
    # * Author: Ankit
    # * Date: 04/02/2019
    # * Reviewed By:
    #
    # @return [Result::Base]
    #
    def perform

      handle_errors_and_exceptions do

        r = validate_and_sanitize
        return r unless r.success?

        r = fetch_token_details
        return r unless r.success?

        r = fetch_default_price_points
        return r unless r.success?

        r = fetch_sub_env_payloads
        return r unless r.success?

        r = fetch_addresses
        return r unless r.success?

        @api_response_data = {
          token: @token,
          price_points: @price_points,
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
    # * Reviewed By:
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
    #
    # * Author: Ankit
    # * Date: 04/02/2019
    # * Reviewed By:
    #
    # @return [Result::Base]
    def fetch_token_details
      token = KitSaasSharedCacheManagement::TokenDetails.new([@client_id]).fetch[@client_id] || {}


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

    # Fetch default price points
    #
    #
    # * Author: Ankit
    # * Date: 04/02/2019
    # * Reviewed By:
    #
    # @return [Result::Base]
    def fetch_default_price_points
      price_points = KitSaasSharedCacheManagement::OstPricePointsDefault.new.fetch

      if price_points.blank?
        return error_with_data(
          'a_s_dm_fd_2',
          'something_went_wrong',
          GlobalConstant::ErrorAction.default
        )
      end

      @price_points = price_points

      success
    end

    # fetch the sub env response data entity
    #
    # * Author: Ankit
    # * Date: 04/02/2019
    # * Reviewed By:
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

      @addresses[:token_holder_address] = token_addresses_data[token_id][GlobalConstant::TokenAddresses.token_holder_master_copy_contract] || ""
      @addresses[:utility_branded_token_contract] = token_addresses_data[token_id][GlobalConstant::TokenAddresses.utility_branded_token_contract] || ""
      @addresses[:branded_token_contract] = token_addresses_data[token_id][GlobalConstant::TokenAddresses.branded_token_contract] || ""
      @addresses[:erc20_contract_address] = token_addresses_data[token_id][GlobalConstant::TokenAddresses.simple_stake_contract] || ""

      company_user_ids = KitSaasSharedCacheManagement::TokenCompanyUser.new([token_id]).fetch || {}

      @addresses[:company_user_id] = company_user_ids[token_id].first || ""

      staker_whitelisted_addresses = KitSaasSharedCacheManagement::StakerWhitelistedAddress.new([token_id]).fetch || {}

      @addresses[:gateway_composer_address] = staker_whitelisted_addresses[token_id][:gateway_composer_address] || ""

      success

    end

  end
end
module TestEconomyManagement

  class Base < ServicesBase

    # Initialize
    #
    # * Author: Puneet
    # * Date: 10/04/2019
    # * Reviewed By: Sunil
    #
    # @params [Integer] client_id (mandatory) - Client Id
    # @params [Hash] client (mandatory) - Client cache data
    # @params [Hash] manager (mandatory) - Manager cache data
    # @params [String] auth_token (optional) - auth token to allow logged in user in main env to access test economy
    #
    # @return [TestEconomyManagement::Base]
    #
    def initialize(params)

      super

      @client_id = @params[:client_id]
      @client = @params[:client]
      @manager = @params[:manager]
      @auth_token = @params[:auth_token]

      @token = nil
      @token_id = nil
      @aux_chain_id = nil

    end

    private

    # Validate and sanitize
    #
    # * Author: Puneet
    # * Date: 10/04/2019
    # * Reviewed By: Sunil
    #
    # @return [Result::Base]
    #
    def validate_and_sanitize

      r = validate
      return r unless r.success?

      r = validate_access
      return r unless r.success?

      success

    end

    # Check is Test Economy Activation is allowed for this Economy
    #
    # * Author: Puneet
    # * Date: 10/04/2019
    # * Reviewed By: Sunil
    #
    # @return [Result::Base]
    #
    def validate_access

      return success if GlobalConstant::Base.sandbox_sub_environment?

      return success if GlobalConstant::Base.activate_test_economy_auth_token.present? &&
          @auth_token == GlobalConstant::Base.activate_test_economy_auth_token &&
          is_ost_managed_economy? && is_ost_manager?

      error_with_data(
          'tem_b_1',
          'unauthorized_to_perform_action',
          GlobalConstant::ErrorAction.default
      )

    end

    # Check if this economy is OST Managed by verifying if all super admin(s) are an OST manager(s)
    #
    # * Author: Puneet
    # * Date: 15/04/2019
    # * Reviewed By:
    #
    # @return [Boolean]
    #
    def is_ost_managed_economy?

      super_admin_manager_ids = ClientManager.super_admins(@client_id).pluck(:manager_id)

      super_admin_managers = {}
      if super_admin_manager_ids.include?(@manager[:id])
        super_admin_managers[@manager[:id]] = @manager
        manager_ids_to_fetch = super_admin_manager_ids - [@manager[:id]]
      else
        manager_ids_to_fetch = super_admin_manager_ids
      end

      if manager_ids_to_fetch.any?
        super_admin_managers.merge!(CacheManagement::Manager.new(manager_ids_to_fetch).fetch)
      end

      super_admin_managers.each do |_, manager|
        return false unless Util::CommonValidator.is_valid_ost_email?(manager[:email])
      end

      true

    end

    # Check if logged in user is an OST manager
    #
    # * Author: Puneet
    # * Date: 15/04/2019
    # * Reviewed By:
    #
    # @return [Boolean]
    #
    def is_ost_manager?
      Util::CommonValidator.is_valid_ost_email?(@manager[:email])
    end

    # Check if request is to mainnet ENV
    #
    # * Author: Puneet
    # * Date: 10/04/2019
    # * Reviewed By: Sunil
    #
    # @return [Boolean]
    #
    def is_main_sub_env?
      GlobalConstant::Base.main_sub_environment?
    end

    # Check if is already registered in mappy server
    #
    # * Author: Puneet
    # * Date: 10/04/2019
    # * Reviewed By: Sunil
    #
    # @return [Boolean]
    #
    def registered_in_mappy_server?
      is_main_sub_env? ? @client[:mainnet_statuses].include?(GlobalConstant::Client.mainnet_registered_in_mappy_server_status) :
          @client[:sandbox_statuses].include?(GlobalConstant::Client.sandbox_registered_in_mappy_server_status)
    end

    # Check if QR code has already been uploaded
    #
    # * Author: Puneet
    # * Date: 10/04/2019
    # * Reviewed By: Sunil
    #
    # @return [Boolean]
    #
    def test_economy_qr_code_uploaded?
      is_main_sub_env? ? @client[:mainnet_statuses].include?(GlobalConstant::Client.mainnet_test_economy_qr_code_uploaded_status) :
          @client[:sandbox_statuses].include?(GlobalConstant::Client.sandbox_test_economy_qr_code_uploaded_status)
    end

    # Find & validate token
    #
    # * Author: Puneet
    # * Date: 10/04/2019
    # * Reviewed By: Sunil
    #
    # Sets @token, @token_id
    #
    # @return [Result::Base]
    #
    def fetch_token

      token_resp = Util::EntityHelper.fetch_and_validate_token(@client_id, 'tem_b')
      return token_resp unless token_resp.success?

      @token = token_resp.data

      # if token is not yet deployed, per its status redirect accordingly
      if @token[:status] != GlobalConstant::ClientToken.deployment_completed
        return error_with_data(
            'tem_b_2',
            'token_not_setup',
            GlobalConstant::ErrorAction.default
        )
      end

      @token_id = @token[:id]
      @aux_chain_id = @token[:aux_chain_id]

      if @token[:stake_currency_id].present?
        @stake_currencies = Util::EntityHelper.fetch_stake_currency_details(@token[:stake_currency_id]).data
      else
        @stake_currencies = {}
      end

      success

    end

    # fetch the sub env response data entity
    #
    # * Author: Puneet
    # * Date: 10/04/2019
    # * Reviewed By: Sunil
    #
    # @return [Result::Base]
    #
    def fetch_sub_env_payloads
      r = SubEnvPayload.new({client_id: @client_id}).perform
      return r unless r.success?

      @sub_env_payloads = r.data[:sub_env_payloads]

      success
    end

    # Url id
    #
    # * Author: Puneet
    # * Date: 10/04/2019
    # * Reviewed By: Sunil
    #
    # @return [String]
    #
    def url_id
      @url_id ||= begin
        string_to_sign = "#{GlobalConstant::Base.environment_name}-#{GlobalConstant::Base.sub_environment_name}-#{@token_id}-#{@client_id}-#{@aux_chain_id}"
        OpenSSL::HMAC.hexdigest("SHA256",
                                GlobalConstant::Base.activate_test_economy_auth_token, string_to_sign)
      end
    end

    # QR Code Data
    #
    # * Author: Puneet
    # * Date: 23/05/2019
    # * Reviewed By:
    #
    # @return [Hash]
    #
    def qr_code_data
      {
          token_id: @token_id,
          token_name: @token[:name],
          token_symbol: @token[:symbol],
          url_id: url_id,
          mappy_api_endpoint: "#{GlobalConstant::DemoMappyServer.api_endpoint}/",
          saas_api_endpoint: GlobalConstant::SaasApi.api_endpoint_for_current_version,
          view_api_endpoint: "#{GlobalConstant::CompanyOtherProductUrls.view_root_url}/#{GlobalConstant::Environment.url_prefix}/"
      }
    end

    # Generate QR Code file S3 Path
    #
    # * Author: Puneet
    # * Date: 10/04/2019
    # * Reviewed By: Sunil
    #
    # @return [String]
    #
    def qr_code_s3_file_path
      "#{GlobalConstant::S3.test_economy_qr_code_folder}/#{@aux_chain_id}/#{url_id}.png"
    end

    # S3 URL for QR Code
    #
    # * Author: Puneet
    # * Date: 10/04/2019
    # * Reviewed By: Sunil
    #
    # @return [String]
    #
    def qr_code_s3_url
      GlobalConstant::S3.public_asset_s3_url(qr_code_s3_file_path)
    end

    # Update attributes in pepo campaigns
    #
    # * Author: Santhosh
    # * Date: 16/07/2019
    # * Reviewed By:
    #
    # @params [Integer] entity_id (mandatory) -  receiver entity id
    # @params [Integer] entity_kind (mandatory) - receiver entity kind
    # @params [Hash] attributes (mandatory) - attributes to update
    # @params [Hash] settings (mandatory) - settings to update
    #
    # @return [Result::Base]
    #
    def update_campaign_attributes(params)
      Email::HookCreator::ClientMileStone.new(
          receiver_entity_id: params[:entity_id],
          receiver_entity_kind: params[:entity_kind],
          mile_stone: params[:mile_stone],
          sub_env: GlobalConstant::Base.sub_environment_name
      ).perform

      success
    end

  end

end

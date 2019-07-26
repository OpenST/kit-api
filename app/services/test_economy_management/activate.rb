module TestEconomyManagement

  class Activate < TestEconomyManagement::Base

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
    # @return [TestEconomyManagement::Activate]
    #
    def initialize(params)

      super

      @client_obj = nil

      @error_responses = []

    end

    # Perform
    #
    # * Author: Puneet
    # * Date: 10/04/2019
    # * Reviewed By: Sunil
    #
    # @return [Result::Base]
    #
    def perform

      handle_errors_and_exceptions do

        r = validate_and_sanitize
        return r unless r.success?

        r = check_activation_status
        return r unless r.success?

        r = fetch_token
        return r unless r.success?

        r = fetch_sub_env_payloads
        return r unless r.success?

        r = fetch_client_obj
        return r unless r.success?

        r = perform_activation
        return r unless r.success?

        r = enqueue_job
        return r unless r.success?

        prepare_response

      end

    end

    private

    # Check if activation is already completed
    #
    # * Author: Puneet
    # * Date: 10/04/2019
    # * Reviewed By: Sunil
    #
    # @return [Result::Base]
    #
    def check_activation_status

      return error_with_data(
          'tem_a_1',
          'token_demo_already_setup',
          GlobalConstant::ErrorAction.default
      ) if registered_in_mappy_server? && test_economy_qr_code_uploaded?

      success

    end

    # Fetch client object
    #
    # * Author: Puneet
    # * Date: 10/04/2019
    # * Reviewed By: Sunil
    #
    # Sets @client_obj
    #
    # @return [Result::Base]
    #
    def fetch_client_obj

      @client_obj = Client.where(id: @client_id).first

      return error_with_data(
          'tem_a_2',
          'client_not_found',
          GlobalConstant::ErrorAction.default
      ) if @client_obj.blank?

      success

    end

    # perform activation
    # 1. Generate & Upload QR code
    # 2. Perform API Call to Demo Mappy Server to register this token
    #
    # * Author: Puneet
    # * Date: 10/04/2019
    # * Reviewed By: Sunil
    #
    # @return [Result::Base]
    #
    def perform_activation

      perform_qr_code_task unless test_economy_qr_code_uploaded?

      perform_registeration_in_mappy_task unless registered_in_mappy_server?

      @client_obj.save! if @client_obj.changed?

      return error_with_data(
          'tem_a_5',
          'something_went_wrong',
          GlobalConstant::ErrorAction.default,
          {
            error_responses: @error_responses
          }
      ) if @error_responses.any?

      success

    end

    # Send invite to self
    #
    # * Author: Puneet
    # * Date: 23/05/2019
    # * Reviewed By:
    #
    # @return [Result::Base]
    #
    def enqueue_job

      BackgroundJob.enqueue(
          PostTestEconomySetupJob,
          {
              manager_id: @manager[:id],
              client_id: @client_id
          }
      )

      success

    end

    # Generate & Upload QR code
    # 
    # * Author: Puneet
    # * Date: 10/04/2019
    # * Reviewed By: Sunil
    #
    # @return [Result::Base]
    #
    def perform_qr_code_task

      qr_code_obj = RQRCode::QRCode.new(qr_code_data.to_json)

      png_image_obj = qr_code_obj.as_png(
          resize_gte_to: false,
          resize_exactly_to: false,
          fill: 'white',
          color: 'black',
          size: 360,
          border_modules: 4,
          module_px_size: 6,
          file: nil
      )

      # Generate image URL from image object
      data_url = png_image_obj.to_data_url

      # extract image data from URL
      body = Base64.decode64(data_url.split(',')[1])

      s3_manager = Aws::S3Manager.new(GlobalConstant::S3.public_access)

      # Upload image to S3
      r = s3_manager.upload(
          qr_code_s3_file_path,
          body,
          GlobalConstant::S3.public_bucket,
          {
              content_type: 'image/png',
              acl: 'public-read',
              content_encoding: 'base64'
          }
      )

      unless r.success?
        @error_responses.push(perform_qr_code_task: r.to_json)
        return r
      end

      if is_main_sub_env?
        @client_obj.send("set_#{GlobalConstant::Client.mainnet_test_economy_qr_code_uploaded_status}")
      else
        @client_obj.send("set_#{GlobalConstant::Client.sandbox_test_economy_qr_code_uploaded_status}")
      end

      success

    end

    # Perform API Call to Demo Mappy Server to register this token
    # 
    # * Author: Puneet
    # * Date: 10/04/2019
    # * Reviewed By: Sunil
    #
    # @return [Result::Base]
    #
    def perform_registeration_in_mappy_task

      api_keys = KitSaasSharedCacheManagement::ApiCredentials.new([@client_id]).fetch[@client_id]
      last_expiring_api_key = api_keys.first

      return error_with_data(
          'tem_a_3',
          'something_went_wrong',
          GlobalConstant::ErrorAction.default
      ) if last_expiring_api_key.blank?

      company_user_ids = KitSaasSharedCacheManagement::TokenCompanyUser.new([@token_id]).fetch[@token_id]
      return error_with_data(
          'tem_a_4',
          'something_went_wrong',
          GlobalConstant::ErrorAction.default
      ) if company_user_ids.blank?

      r = DemoMappyServerApi.new.send_request_of_type(
          'post',
          'setup/create-token',
          {
              name: @token[:name],
              symbol: @token[:symbol],
              ost_token_id: @token_id,
              conversion_factor: @token[:conversion_factor],
              pc_token_holder_uuid: company_user_ids.first,
              chain_id: @aux_chain_id,
              api_key: last_expiring_api_key[:key],
              api_secret: last_expiring_api_key[:secret],
              api_endpoint: GlobalConstant::SaasApi.api_endpoint_for_current_version,
              url_id: url_id
          }
      )

      unless r.success?
        @error_responses.push(perform_registeration_in_mappy_task: r.to_json)
        return r
      end

      if is_main_sub_env?
        @client_obj.send("set_#{GlobalConstant::Client.mainnet_registered_in_mappy_server_status}")
      else
        @client_obj.send("set_#{GlobalConstant::Client.sandbox_registered_in_mappy_server_status}")
      end

      update_campaign_attributes({
                                     entity_id: @client_id,
                                     entity_kind: GlobalConstant::EmailServiceApiCallHook.client_receiver_entity_kind,
                                     attributes: { GlobalConstant::PepoCampaigns.ost_wallet_setup =>  GlobalConstant::PepoCampaigns.attribute_set },
                                     settings: {},
                                     mile_stone: GlobalConstant::PepoCampaigns.ost_wallet_setup
                                 })

      success

    end

    # prepare response
    #
    # * Author: Puneet
    # * Date: 10/04/2019
    # * Reviewed By: Sunil
    #
    # @return [Result::Base]
    #
    def prepare_response
      success_with_data(
        {
          token: @token,
          stake_currencies: @stake_currencies,
          client: @client_obj.formatted_cache_data,
          manager: @manager,
          sub_env_payloads: @sub_env_payloads,
          test_economy_details: {
            qr_code_url: qr_code_s3_url
          }
        }
      )
    end

  end

end

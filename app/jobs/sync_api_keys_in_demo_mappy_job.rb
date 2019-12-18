class SyncApiKeysInDemoMappyJob < ApplicationJob

  queue_as GlobalConstant::Sidekiq.queue_name :default_medium_priority_queue

  include Util::ResultHelper

  # Perform
  #
  # * Author: Puneet
  # * Date: 13/04/2019
  # * Reviewed By:
  #
  # @param [Integer] client_id (mandatory) - client id
  #
  def perform(params)

    init_params(params)

    r = fetch_client
    return notify_devs(r) unless r.success?

    has_setup_demo_app = GlobalConstant::Base.main_sub_environment? ?
        @client[:mainnet_statuses].include?(GlobalConstant::Client.mainnet_registered_in_mappy_server_status) :
        @client[:sandbox_statuses].include?(GlobalConstant::Client.sandbox_registered_in_mappy_server_status)

    Rails.logger.info "=======has_setup_demo_app===== #{has_setup_demo_app}"

    # return if token has not been registered in Mappy
    return success unless has_setup_demo_app

    r = fetch_token
    return notify_devs(r) unless r.success?

    r = fetch_api_credentials
    return notify_devs(r) unless r.success?

    # Webhook secret would be added if
    fetch_webhook_secret

    r = sync_in_demo_mappy
    return notify_devs(r) unless r.success?

    success

  end

  # init params
  #
  # * Author: Puneet
  # * Date: 13/04/2019
  # * Reviewed By:
  #
  # @param [Hash] params
  #
  def init_params(params)
    Rails.logger.info "===params=======#{params}"
    @client_id = params[:client_id].to_i
    @client = nil
    @show_keys_enable_flag = params[:show_keys_enable_flag].to_i
    @email_already_sent_flag = params[:email_already_sent_flag].to_i
    @token_id = nil
    @last_expiring_api_credentials = nil
    @data_to_sync = nil
  end

  # Fetch Client
  #
  # * Author: Puneet
  # * Date: 13/04/2019
  # * Reviewed By:
  #
  def fetch_client

    client_fetch_resp = Util::EntityHelper.fetch_and_validate_client(@client_id, 'j_sakidmj')
    return client_fetch_resp unless client_fetch_resp.success?

    @client = client_fetch_resp.data

    success

  end

  # Fetch Token
  #
  # * Author: Puneet
  # * Date: 13/04/2019
  # * Reviewed By:
  #
  def fetch_token

    token_resp = Util::EntityHelper.fetch_and_validate_token(@client_id, 'j_sakidmj')
    return token_resp unless token_resp.success?

    @token_id = token_resp.data[:id]

    success

  end

  # Fetch API Keys
  #
  # * Author: Puneet
  # * Date: 13/04/2019
  # * Reviewed By:
  #
  def fetch_api_credentials



    r = ClientManagement::ApiCredentials::Fetch.new(client_id: @client_id,
                                                    show_keys_enable_flag: @show_keys_enable_flag,
                                                    email_already_sent_flag: @email_already_sent_flag).perform
    return r unless r.success?

    api_credentials = r.data[:api_keys]

    @last_expiring_api_credentials = api_credentials.first

    return error_with_data(
        'j_sakidmj_1',
        'something_went_wrong',
        GlobalConstant::ErrorAction.default
    ) if @last_expiring_api_credentials.blank?

    @data_to_sync = {
        ost_token_id: @token_id,
        api_endpoint: GlobalConstant::SaasApi.api_endpoint_for_current_version,
        api_key: @last_expiring_api_credentials[:key],
        api_secret: @last_expiring_api_credentials[:secret]
    }

    Rails.logger.info "======@data_to_sync====333333333333===== #{@data_to_sync}"

    success

  end

  # Fetch webhook secret to sync to demo
  #
  def fetch_webhook_secret
    Rails.logger.info "======@data_to_sync====111111111===== #{@data_to_sync}"
    if @client[:sandbox_statuses].include?(GlobalConstant::Client.webhook_registered_in_mappy_server_status)
      @data_to_sync.merge!(KitSaasSharedCacheManagement::WebhookSecret.new([@client_id]).fetch[@client_id] || {})
    end
  end

  # Sync credentials in Demo Mappy Server
  #
  # * Author: Puneet
  # * Date: 13/04/2019
  # * Reviewed By:
  #
  def sync_in_demo_mappy

    Rails.logger.info "======@data_to_sync====22222222===== #{@data_to_sync}"

    DemoMappyServerApi.new.send_request_of_type(
    'post', 'setup/update-token', @data_to_sync)

  end

  # Notify devs on error response
  #
  # * Author: Puneet
  # * Date: 13/04/2019
  # * Reviewed By:
  #
  def notify_devs(response)
    ApplicationMailer.notify(
        data: {
          params: {client_id: @client_id}
        },
        body: {
          response: response.to_json
        },
        subject: 'Problem in SyncApiKeysInDemoMappyJob'
    ).deliver
  end

end

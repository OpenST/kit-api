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

    r = fetch_token
    return r unless r.success?

    r = fetch_api_credentials
    return r unless r.success?

    r = sync_in_demo_mappy
    return r unless r.success?

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
    @client_id = params[:client_id].to_i
    @token_id = nil
    @last_expiring_api_credentials = nil
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

  end

  # Fetch API Keys
  #
  # * Author: Puneet
  # * Date: 13/04/2019
  # * Reviewed By:
  #
  def fetch_api_credentials

    r = ClientManagement::ApiCredentials::Fetch.new(client_id: @client_id).perform
    return r unless r.success?

    api_credentials = r.data[:api_keys]

    @last_expiring_api_credentials = api_credentials.first

    return error_with_data(
        'j_sakidmj_1',
        'something_went_wrong',
        GlobalConstant::ErrorAction.default
    ) if @last_expiring_api_credentials.blank?

    success

  end

  # Sync credentials in Demo Mappy Server
  #
  # * Author: Puneet
  # * Date: 13/04/2019
  # * Reviewed By:
  #
  def sync_in_demo_mappy

    DemoMappyServerApi.new.send_request_of_type(
    'post',
    'setup/update-token',
    {
        ost_token_id: @token_id,
        api_endpoint: GlobalConstant::SaasApi.api_endpoint_for_current_version,
        api_key: @last_expiring_api_credentials[:key],
        api_secret: @last_expiring_api_credentials[:secret]
      }
    )

  end

end

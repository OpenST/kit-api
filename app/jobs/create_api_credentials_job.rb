class CreateApiCredentialsJob < ApplicationJob

  queue_as GlobalConstant::Sidekiq.queue_name :default_medium_priority_queue

  # Perform
  #
  # * Author: Puneet
  # * Date: 02/02/2018
  # * Reviewed By:
  #
  # @param [Hash] manager_id (mandatory) - manager id
  #
  def perform(params)

    init_params(params)

    create_api_credentials

    notify_devs

  end

  # init params
  #
  # * Author: Puneet
  # * Date: 02/02/2018
  # * Reviewed By:
  #
  # @param [Hash] params
  #
  def init_params(params)
    @client_id = params[:client_id].to_i
    @failed_logs = {}
  end

  # Create API credentials and insert in database
  #
  # * Author: Ankit
  # * Date: 05/02/2019
  # * Reviewed By:
  #
  #
  def create_api_credentials
    r = ::ApiCredentials::Create.new({client_id:@client_id}).perform
    @failed_logs[:create_api_credentials] = r.to_hash unless r.success?
  end

  # Send mail
  #
  # * Author: Puneet
  # * Date: 09/12/2018
  # * Reviewed By:
  #
  def notify_devs
    ApplicationMailer.notify(
      data: @failed_logs,
      body: {client_id: @client_id},
      subject: 'Exception in CreateApiCredentialsJob'
    ).deliver if @failed_logs.present?
  end

end
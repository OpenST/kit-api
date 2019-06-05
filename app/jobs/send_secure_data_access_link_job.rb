class SendSecureDataAccessLinkJob < ApplicationJob

  queue_as GlobalConstant::Sidekiq.queue_name :default_medium_priority_queue

  # Perform
  #
  # * Author: Dhananjay
  # * Date: 01/06/2019
  # * Reviewed By:
  #
  # @params [Hash] manager_id (mandatory) - manager id
  # @params [Hash] manager_device_id (mandatory) - manager device id
  #
  def perform(params)

    init_params(params)

    send_secure_data_access_link

    notify_devs

  end

  # init params
  #
  # * Author: Dhananjay
  # * Date: 01/06/2019
  # * Reviewed By:
  #
  # @param [Hash] params
  #
  def init_params(params)
    @manager_id = params[:manager_id].to_i

    @failed_logs = {}
  end

  # Generate and send secure data access verification token
  #
  # * Author: Dhananjay
  # * Date: 01/06/2019
  # * Reviewed By:
  #
  def send_secure_data_access_link
    r = DeveloperManagement::SendSecureDataAccessLink.new(manager_id: @manager_id).perform
    @failed_logs[:send_device_verification_link] = r.to_hash unless r.success?
  end

  # Send error notification mail if failed
  #
  # * Author: Dhananjay
  # * Date: 01/06/2019
  # * Reviewed By:
  #
  def notify_devs
    ApplicationMailer.notify(
      data: @failed_logs,
      body: {manager_id: @manager_id},
      subject: 'Exception in SendSecureDataAccessLinkJob'
    ).deliver if @failed_logs.present?
  end
end
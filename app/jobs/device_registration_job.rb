class DeviceRegistrationJob < ApplicationJob

  queue_as GlobalConstant::Sidekiq.queue_name :default_medium_priority_queue

  # Perform
  #
  # * Author: Ankit
  # * Date: 21/05/2019
  # * Reviewed By:
  #
  # @params [Hash] manager_id (mandatory) - manager id
  # @params [Hash] manager_device_id (mandatory) - manager device id
  #
  def perform(params)

    init_params(params)

    send_device_verification_link

    notify_devs

  end

  # init params
  #
  # * Author: Ankit
  # * Date: 21/05/2019
  # * Reviewed By:
  #
  # @param [Hash] params
  #
  def init_params(params)
    @manager_id = params[:manager_id].to_i

    @manager_device_id = params[:manager_device_id].to_i
    @failed_logs = {}
  end

  # Generate and send device verification token
  #
  # * Author: Ankit
  # * Date: 21/05/2019
  # * Reviewed By:
  #
  def send_device_verification_link
    r = ManagerManagement::SendDeviceVerificationLink.new(manager_id: @manager_id,manager_device_id: @manager_device_id).perform
    @failed_logs[:send_device_verification_link] = r.to_hash unless r.success?
  end

  # Send mail
  #
  # * Author: Puneet
  # * Date: 09/12/2018
  # * Reviewed By: Kedar
  #
  def notify_devs
    ApplicationMailer.notify(
      data: @failed_logs,
      body: {manager_id: @manager_id},
      subject: 'Exception in SignUpJob'
    ).deliver if @failed_logs.present?
  end
end
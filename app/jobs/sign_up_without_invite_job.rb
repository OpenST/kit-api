class SignUpWithoutInviteJob < ApplicationJob

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

    generate_email_verification_link

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
    @manager_id = params[:manager_id].to_i
    @failed_logs = {}
  end

  # Generate email verification link
  #
  # * Author: Puneet
  # * Date: 09/12/2018
  # * Reviewed By:
  #
  def generate_email_verification_link
    ManagerManagement::SendDoubleOptInLink.new(manager_id: @manager_id).perform
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
        body: {manager_id: @manager_id},
        subject: 'Exception in SignUpWithoutInviteJob'
    ).deliver if @failed_logs.present?
  end

end

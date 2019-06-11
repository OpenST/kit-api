class PostTestEconomySetupJob < ApplicationJob

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

    send_self_invite_link

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
    @client_id = params[:client_id].to_i
    @manager = CacheManagement::Manager.new([@manager_id]).fetch[@manager_id]
    @client = CacheManagement::Client.new([@client_id]).fetch[@client_id]
    @failed_logs = {}
  end

  # Generate and send self invite
  #
  # * Author: Puneet
  # * Date: 09/12/2018
  # * Reviewed By:
  #
  def send_self_invite_link
    r = TestEconomyManagement::Invite.new({
                                              client_id: @client_id,
                                              client: @client,
                                              manager: @manager,
                                              email_addresses: @manager[:email]
                                          }).perform
    @failed_logs[:send_invite_link] = r.to_hash unless r.success?
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
        subject: 'Exception in PostTestEconomySetupJob'
    ).deliver if @failed_logs.present?
  end

end

class InviteJob < ApplicationJob

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

    add_contact_in_email_service

    send_invite_link

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
    @invite_token = params[:invite_token]
    @manager = CacheManagement::Manager.new([@manager_id]).fetch[@manager_id]
    @failed_logs = {}
  end

  # Add contact in Pepo Campaigns
  #
  # * Author: Puneet
  # * Date: 09/12/2018
  # * Reviewed By:
  #
  def add_contact_in_email_service

    Email::HookCreator::AddContact.new(
        email: @manager[:email],
        custom_attributes: {
            GlobalConstant::PepoCampaigns.user_registered_attribute => GlobalConstant::PepoCampaigns.user_registered_value
        }
    ).perform

  end

  # Generate and send email verification link
  #
  # * Author: Puneet
  # * Date: 09/12/2018
  # * Reviewed By:
  #
  def send_invite_link
    puts "@invite_link #{@invite_token}"
    r = Email::HookCreator::SendTransactionalMail.new(
        email: @manager[:email],
        template_name: GlobalConstant::PepoCampaigns.invite_manager_template,
        template_vars: {
            invite_token: CGI.escape(@invite_token),
            company_web_domain: GlobalConstant::CompanyWeb.domain
        }
    ).perform
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
        subject: 'Exception in InviteJob'
    ).deliver if @failed_logs.present?
  end

end

class SignUpJob < ApplicationJob

  queue_as GlobalConstant::Sidekiq.queue_name :default_medium_priority_queue

  # Perform
  #
  # * Author: Puneet
  # * Date: 02/02/2018
  # * Reviewed By: Kedar
  #
  # @param [Hash] manager_id (mandatory) - manager id
  #
  def perform(params)

    init_params(params)

    add_contact_in_email_service

    send_double_optin_link if @manager[:properties].exclude?(GlobalConstant::Manager.has_verified_email_property)

    notify_devs

  end

  # init params
  #
  # * Author: Puneet
  # * Date: 02/02/2018
  # * Reviewed By: Kedar
  #
  # @param [Hash] params
  #
  def init_params(params)
    @manager_id = params[:manager_id].to_i
    @manager = CacheManagement::Manager.new([@manager_id]).fetch[@manager_id]
    @platform_marketing = params[:platform_marketing]
    @manager_first_name = params[:manager_first_name]
    @manager_last_name = params[:manager_last_name]
    @failed_logs = {}
  end

  # Add contact in Pepo Campaigns
  #
  # * Author: Puneet
  # * Date: 09/12/2018
  # * Reviewed By: Kedar
  #
  def add_contact_in_email_service

    Email::HookCreator::AddContact.new(
        receiver_entity_id: @manager_id,
        receiver_entity_kind: GlobalConstant::EmailServiceApiCallHook.manager_receiver_entity_kind,
        custom_attributes: {
            GlobalConstant::PepoCampaigns.platform_signup_attribute => GlobalConstant::PepoCampaigns.platform_signup_value,
            GlobalConstant::PepoCampaigns.platform_marketing_attribute => @platform_marketing,
            GlobalConstant::PepoCampaigns.manager_first_name_attribute => @manager_first_name,
            GlobalConstant::PepoCampaigns.manager_last_name_attribute => @manager_last_name
        }
    ).perform

  end

  # Generate and send email verification link
  #
  # * Author: Puneet
  # * Date: 09/12/2018
  # * Reviewed By: Kedar
  #
  def send_double_optin_link
    r = ManagerManagement::SendDoubleOptInLink.new(manager_id: @manager_id).perform
    @failed_logs[:send_double_opt_in_link] = r.to_hash unless r.success?
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

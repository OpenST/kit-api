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

    fetch_super_admin_privilege

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
    @client_id = params[:client_id]
    @super_admin = nil

    @failed_logs = {}
  end

  # Fetch super admin privilege
  #
  # * Author: Santhosh
  # * Date: 24/07/2019
  # * Reviewed By:
  #
  # @return [Result::Base]
  #
  def fetch_super_admin_privilege

    client_manager = CacheManagement::ClientManager.new([@manager_id],
                                                         { client_id: @client_id }).fetch[@manager_id]

    if client_manager[:privileges].include?(GlobalConstant::ClientManager.is_super_admin_privilege)
      @super_admin = GlobalConstant::PepoCampaigns.attribute_set
    else
      @super_admin = GlobalConstant::PepoCampaigns.attribute_unset
    end

    success
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
            GlobalConstant::PepoCampaigns.manager_last_name_attribute => @manager_last_name,
            GlobalConstant::PepoCampaigns.super_admin => @super_admin
        }
    ).perform

    client_mile_stone = ClientMileStone.new(client_id: @client_id, manager_id: @manager_id)

    client_mile_stone.update_mile_stones_for_current_admin

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

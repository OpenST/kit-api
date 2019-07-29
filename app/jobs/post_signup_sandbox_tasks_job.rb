class PostSignupSandboxTasksJob < ApplicationJob

  queue_as GlobalConstant::Sidekiq.queue_name :default_medium_priority_queue

  # Perform
  #
  # * Author: Santhosh
  # * Date: 26/07/2019
  # * Reviewed By:
  #
  # @param [Hash] manager_id (mandatory) - manager id
  # @param [Hash] client_id (mandatory) - client id
  #
  def perform(params)

    init_params(params)

    fetch_campaign_automation_attributes

    update_contact_in_email_service

    notify_devs

  end

  # init params
  #
  # * Author: Santhosh
  # * Date: 26/07/2019
  # * Reviewed By:
  #
  # @param [Hash] params
  #
  def init_params(params)
    @manager_id = params[:manager_id].to_i
    @client_id = params[:client_id].to_i

    @token_name = nil
    @testnet_view_link = nil
    @failed_logs = {}

    @manager = CacheManagement::Manager.new([@manager_id]).fetch[@manager_id]
  end

  # Fetch campaign automation attributes
  #
  # * Author: Santhosh
  # * Date: 26/07/2019
  # * Reviewed By:
  #
  # @returns [Hash]
  #
  def fetch_campaign_automation_attributes
    campaign_attribute_manager = CampaignAttributeManager.new({ client_id: @client_id, manager_id: @manager_id })

    r = campaign_attribute_manager.fetch_automation_campaign_attributes
    return r unless r.success?

    @attributes_hash = r.data
  end

  # Update contact in Pepo Campaigns
  #
  # * Author: Santhosh
  # * Date: 26/07/2019
  # * Reviewed By:
  #
  def update_contact_in_email_service

    r = Email::HookCreator::UpdateContact.new(
        receiver_entity_id: @manager_id,
        receiver_entity_kind: GlobalConstant::EmailServiceApiCallHook.manager_receiver_entity_kind,
        custom_attributes: @attributes_hash
    ).perform

    @failed_logs[@manager_id] = r.to_hash unless r.success?
  end

  # Send mail
  #
  # * Author: Santhosh
  # * Date: 26/07/2019
  # * Reviewed By:
  #
  def notify_devs
    ApplicationMailer.notify(
        data: @failed_logs,
        body: { manager_id: @manager_id },
        subject: 'Exception in Post signup sandbox tasks job'
    ).deliver if @failed_logs.present?
  end

end

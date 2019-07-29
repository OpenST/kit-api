# Task to populate client mile stone properties for existing clients
#
# * Author: Santhosh
# * Date: 19/07/2019
# * Reviewed By:
#
namespace :one_timers do

  desc "Usage: rake RAILS_ENV=staging one_timers:populate_client_mile_stones"

  task :populate_client_mile_stones => :environment do

    Client.all.each do |client|
      client_id = client[:id]
      client_hash = client.formatted_cache_data
      sub_env = GlobalConstant::Base.main_sub_environment? ? 'mainnet' : 'sandbox'
      attribute_hash = {}

      puts "**** Started processing for client id #{client_id} in #{sub_env} environment *****"

      @token = Token.where(client_id: client_id, status: GlobalConstant::ClientToken.deployment_completed).first

      puts "==== Deployed token present status for #{client_id} - #{@token.present?} ===="

      if @token.present?
        client.send("set_#{sub_env}_#{GlobalConstant::PepoCampaigns.token_setup}")
        attribute_hash[GlobalConstant::PepoCampaigns.token_setup] = GlobalConstant::PepoCampaigns.attribute_set if GlobalConstant::Base.sandbox_sub_environment?

        stake_and_mint = Workflow.where(client_id: client_id,
                       kind: GlobalConstant::Workflow.bt_stake_and_mint,
                       status: GlobalConstant::Workflow.completed).first

        puts "==== Stake and mint done status for #{client_id} - #{stake_and_mint.present?} ===="

        if stake_and_mint.present?
          client.send("set_#{sub_env}_#{GlobalConstant::PepoCampaigns.stake_and_mint}")
          attribute_hash[GlobalConstant::PepoCampaigns.stake_and_mint] = GlobalConstant::PepoCampaigns.attribute_set if GlobalConstant::Base.sandbox_sub_environment?
        end

        invitee = TestEconomyInvite.where(token_id: @token[:id]).pluck

        puts "==== Wallet users invited status for token id #{@token[:id]} - #{invitee.present?} ===="

        if invitee.present?
          client.send("set_#{sub_env}_#{GlobalConstant::PepoCampaigns.ost_wallet_invited_users}")
          attribute_hash[GlobalConstant::PepoCampaigns.ost_wallet_invited_users] = GlobalConstant::PepoCampaigns.attribute_set
        end

        if @token[:name].present?
          attribute_hash[GlobalConstant::PepoCampaigns.token_name] = @token[:name] if GlobalConstant::Base.sandbox_sub_environment?
        end

        if GlobalConstant::Base.sandbox_sub_environment?
          client_mile_stone = ClientMileStone.new({})
          view_link = client_mile_stone.fetch_view_link(@token[:id], GlobalConstant::Environment.url_prefix)
          attribute_hash[GlobalConstant::PepoCampaigns.testnet_view_link] = CGI.escape(view_link) if view_link.present?
        end
      end

      if GlobalConstant::Base.sandbox_sub_environment?
        puts "===== Sandbox statuses #{client_hash[:sandbox_statuses]}"

        next if client_hash[:sandbox_statuses].blank?

        wallet_setup_done = client_hash[:sandbox_statuses].include?(GlobalConstant::Client.sandbox_registered_in_mappy_server_status)

        puts "==== Wallet setup done status for client_id #{client_id} - #{wallet_setup_done} ===="

        if wallet_setup_done
          attribute_hash[GlobalConstant::PepoCampaigns.ost_wallet_setup] = GlobalConstant::PepoCampaigns.attribute_set
        end
      end

      create_hooks_for_admins(client_id, attribute_hash)

      client.save!
    end

  end

  # Perform
  #
  # * Author: Santhosh
  # * Date: 19/07/2019
  # * Reviewed By:
  #
  # @return [Result::Base]
  #
  def create_hooks_for_admins(client_id, attributes_hash)
    puts "==== Creating hooks on admins for client_id #{client_id} for attributes #{attributes_hash}"

    manager_ids = []

    super_admins = {}

    ClientManager.admins(client_id).all.each do |client_manager|
      formatted_cm = client_manager.formatted_cache_data
      manager_ids << client_manager[:manager_id]
      super_admins[client_manager[:manager_id]] = 1 if formatted_cm[:privileges].include?(GlobalConstant::ClientManager.is_super_admin_privilege)
    end

    managers = CacheManagement::Manager.new(manager_ids).fetch

    # Only active managers should have the mile stones updated in pepo campaigns
    managers.each do |manager_id, manager|
      attributes_hash[GlobalConstant::PepoCampaigns.super_admin] = nil
      next if manager[:status] != GlobalConstant::Manager.active_status

      attributes_hash[GlobalConstant::PepoCampaigns.super_admin] = 1 if super_admins[manager_id].present?
      update_contact(manager_id, attributes_hash)
    end
  end

  # Perform
  #
  # * Author: Santhosh
  # * Date: 19/07/2019
  # * Reviewed By:
  #
  # @return [Result::Base]
  #
  def update_contact(manager_id, attributes_hash)
    r = Email::HookCreator::UpdateContact.new(
        receiver_entity_id: manager_id,
        receiver_entity_kind: GlobalConstant::EmailServiceApiCallHook.manager_receiver_entity_kind,
        custom_attributes: attributes_hash,
        user_settings: {}
    ).perform

    puts "==== Hook creation response #{r.inspect}" unless r.success?
  end

end
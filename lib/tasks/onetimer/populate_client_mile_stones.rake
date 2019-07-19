# Task to populate client mile stone properties for existing clients
#
# * Author: Santhosh
# * Date: 19/07/2019
# * Reviewed By:
#
namespace :one_timers do

  desc "Usage: rake RAILS_ENV=staging one_timers:populate_client_mile_stones"

  task :populate_client_mile_stones => :environment do

    Client.limit(2).each do |client|
      client_id = client[:id]
      client_hash = client.formatted_cache_data
      sub_env = GlobalConstant::Base.sub_environment_name
      attribute_hash = {}

      Rails.logger.info "**** Started processing for client id #{client_id} in #{sub_env} environment *****"

      @token = Token.where(client_id: client_id, status: GlobalConstant::ClientToken.deployment_completed).first

      Rails.logger.info "==== Deployed token present status for #{client_id} - #{@token.present?} ===="

      if @token.present?
        client.send("set_#{sub_env}_#{GlobalConstant::PepoCampaigns.token_setup}")
        attribute_hash[GlobalConstant::PepoCampaigns.token_setup] = GlobalConstant::PepoCampaigns.attribute_set if GlobalConstant::Base.sandbox_sub_environment?


        # Assuming if the token is setup user made token get api call
        client.send("set_#{sub_env}_#{GlobalConstant::PepoCampaigns.first_api_call}")
        attribute_hash[GlobalConstant::PepoCampaigns.first_api_call] = GlobalConstant::PepoCampaigns.attribute_set if GlobalConstant::Base.sandbox_sub_environment?


        stake_and_mint = Workflow.where(client_id: client_id,
                       kind: GlobalConstant::Workflow.bt_stake_and_mint,
                       status: GlobalConstant::Workflow.completed).first

        Rails.logger.info "==== Stake and mint done status for #{client_id} - #{stake_and_mint.present?} ===="

        if stake_and_mint.present?
          client.send("set_#{sub_env}_#{GlobalConstant::PepoCampaigns.stake_and_mint}")
          attribute_hash[GlobalConstant::PepoCampaigns.stake_and_mint] = GlobalConstant::PepoCampaigns.attribute_set if GlobalConstant::Base.sandbox_sub_environment?
        end

        invitee = TestEconomyInvite.where(token_id: @token[:id]).pluck

        Rails.logger.info "==== Wallet users invited status for token id #{@token[:id]} - #{invitee.present?} ===="

        if invitee.present?
          client.send("set_#{sub_env}_#{GlobalConstant::PepoCampaigns.ost_wallet_invited_users}")
          attribute_hash[GlobalConstant::PepoCampaigns.ost_wallet_invited_users] = GlobalConstant::PepoCampaigns.attribute_set
        end
      end

      if GlobalConstant::Base.sandbox_sub_environment?
        Rails.logger.info "===== Sandbox statuses #{client_hash["sandbox_statuses"]}"

        break if client_hash["sandbox_statuses"].blank?

        wallet_setup_done = client_hash["sandbox_statuses"].include?(GlobalConstant::Client.sandbox_registered_in_mappy_server_status)

        Rails.logger.info "==== Wallet setup done status for client_id #{client_id} - #{wallet_setup_done} ===="

        if wallet_setup_done
          attribute_hash[GlobalConstant::PepoCampaigns.ost_wallet_setup] = GlobalConstant::PepoCampaigns.attribute_set
        end
      end

      create_hooks_for_admins(client_id, attribute_hash)

      client.save!
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
      Rails.logger.info "==== Creating hooks on admins for client_id #{client_id} for attributes #{attributes_hash}"

      ClientManager.admins(client_id).each do |client_manager|
        update_contact(client_manager[:manager_id], attributes_hash)
      end

      success
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

      Rails.logger.info "==== Hook creation response #{r.inspect}"

      success
    end

  end

end
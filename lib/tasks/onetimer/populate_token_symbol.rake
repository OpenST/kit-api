# Task to populate token symbol for existing super admins
#
# * Author: Santhosh
# * Date: 1/08/2019
# * Reviewed By:
#
namespace :one_timers do

  desc "Usage: rake RAILS_ENV=staging one_timers:populate_token_symbol"

  task :populate_token_symbol => :environment do

    Client.all.each do |client|
      client_id = client[:id]
      sub_env = GlobalConstant::Base.main_sub_environment? ? 'mainnet' : 'sandbox'

      break if GlobalConstant::Base.main_sub_environment?

      puts "**** Started processing for client id #{client_id} in #{sub_env} environment *****"

      @token = Token.where(client_id: client_id, status: GlobalConstant::ClientToken.deployment_completed).first

      puts "==== Deployed token present status for #{client_id} - #{@token.present?} ===="

      next unless @token.present?

      create_hooks_for_admins(client_id, {})
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

    ClientManager.admins(client_id).all.each do |client_manager|
      manager_ids << client_manager[:manager_id]
    end

    managers = CacheManagement::Manager.new(manager_ids).fetch

    # Only active managers should have the mile stones updated in pepo campaigns
    managers.each do |manager_id, manager|
      next if manager[:status] != GlobalConstant::Manager.active_status

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
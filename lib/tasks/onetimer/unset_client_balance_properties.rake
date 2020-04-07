# Task to unset client low balance properties.
#
# * Author: Shlok
# * Date: 11/03/2020
# * Reviewed By:
#
namespace :one_timers do

  desc "Usage: rake RAILS_ENV=staging one_timers:unset_client_balance_properties"

  task :unset_client_balance_properties => :environment do

    Client.all.each do |client|
      client_id = client[:id]
      client_hash = client.formatted_cache_data
      sub_env = GlobalConstant::Base.main_sub_environment? ? 'mainnet' : 'sandbox'

      puts "**** Started processing for client id #{client_id} in #{sub_env} environment *****"

      @token = Token.where(client_id: client_id, status: GlobalConstant::ClientToken.deployment_completed).first

      if @token.present?

        if GlobalConstant::Base.sandbox_sub_environment?
          unset_props_arr = []
          if client_hash[:sandbox_statuses].include?(GlobalConstant::Client.sandbox_stake_and_mint_property)
            if client_hash[:sandbox_statuses].include?(GlobalConstant::Client.sandbox_low_balance_email_status)
              unset_props_arr.push(GlobalConstant::Client.sandbox_low_balance_email_status)
            end
            if client_hash[:sandbox_statuses].include?(GlobalConstant::Client.sandbox_very_low_balance_email_status)
              unset_props_arr.push(GlobalConstant::Client.sandbox_very_low_balance_email_status)
            end
            if client_hash[:sandbox_statuses].include?(GlobalConstant::Client.sandbox_zero_balance_email_status)
              unset_props_arr.push(GlobalConstant::Client.sandbox_zero_balance_email_status)
            end
          end

          if unset_props_arr.present?
            Client.atomic_update_bitwise_columns(client_id, [], unset_props_arr)
          end
        end

        if GlobalConstant::Base.main_sub_environment?
          unset_props_arr = []
          if client_hash[:mainnet_statuses].include?(GlobalConstant::Client.mainnet_stake_and_mint_property)
            if client_hash[:mainnet_statuses].include?(GlobalConstant::Client.mainnet_low_balance_email_status)
              unset_props_arr.push(GlobalConstant::Client.mainnet_low_balance_email_status)
            end
            if client_hash[:mainnet_statuses].include?(GlobalConstant::Client.mainnet_very_low_balance_email_status)
              unset_props_arr.push(GlobalConstant::Client.mainnet_very_low_balance_email_status)
            end
            if client_hash[:mainnet_statuses].include?(GlobalConstant::Client.mainnet_zero_balance_email_status)
              unset_props_arr.push(GlobalConstant::Client.mainnet_zero_balance_email_status)
            end
          end
          if unset_props_arr.present?
            Client.atomic_update_bitwise_columns(client_id, [], unset_props_arr)
          end
        end
      end
    end
  end
end

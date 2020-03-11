# Task to sync client low balance properties with token properties.
#
# * Author: Shlok
# * Date: 11/03/2020
# * Reviewed By:
#
namespace :one_timers do

  desc "Usage: rake RAILS_ENV=staging one_timers:sync_client_token_balance_properties"

  task :sync_client_token_balance_properties => :environment do

    Client.all.each do |client|
      client_id = client[:id]
      client_hash = client.formatted_cache_data
      sub_env = GlobalConstant::Base.main_sub_environment? ? 'mainnet' : 'sandbox'

      puts "**** Started processing for client id #{client_id} in #{sub_env} environment *****"

      @token = Token.where(client_id: client_id, status: GlobalConstant::ClientToken.deployment_completed).first

      if @token.present?
        if GlobalConstant::Base.sandbox_sub_environment?
          set_props_arr = []
          if client_hash[:sandbox_statuses].include?(GlobalConstant::Client.sandbox_stake_and_mint_property)
            if client_hash[:sandbox_statuses].include?(GlobalConstant::Client.sandbox_low_balance_email_status)
              set_props_arr.push(GlobalConstant::ClientToken.low_balance_email)
            end
            if client_hash[:sandbox_statuses].include?(GlobalConstant::Client.sandbox_very_low_balance_email_status)
              set_props_arr.push(GlobalConstant::ClientToken.very_low_balance_email)
            end
            if client_hash[:sandbox_statuses].include?(GlobalConstant::Client.sandbox_zero_balance_email_status)
              set_props_arr.push(GlobalConstant::ClientToken.zero_balance_email)
            end
          end
          Token.atomic_update_bitwise_columns(@client_id, set_props_arr, [])

        elsif GlobalConstant::Base.main_sub_environment?
          set_props_arr = []
          if client_hash[:mainnet_statuses].include?(GlobalConstant::Client.mainnet_stake_and_mint_property)
            if client_hash[:mainnet_statuses].include?(GlobalConstant::Client.mainnet_low_balance_email_status)
              set_props_arr.push(GlobalConstant::ClientToken.low_balance_email)
            end
            if client_hash[:mainnet_statuses].include?(GlobalConstant::Client.mainnet_very_low_balance_email_status)
              set_props_arr.push(GlobalConstant::ClientToken.very_low_balance_email)
            end
            if client_hash[:mainnet_statuses].include?(GlobalConstant::Client.mainnet_zero_balance_email_status)
              set_props_arr.push(GlobalConstant::ClientToken.zero_balance_email)
            end
          end
            Token.atomic_update_bitwise_columns(@client_id, set_props_arr, [])
        end
      end
    end
  end
end

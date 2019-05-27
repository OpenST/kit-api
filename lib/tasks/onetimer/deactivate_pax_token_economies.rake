# One timer to deactivate all economies whose stake currency was PAX
#
# * Author: Ankit
# * Date: 15/05/2019
# * Reviewed By:
#
namespace :one_timers do

  desc "Usage: rake RAILS_ENV=staging one_timers:deactivate_pax_token_economies"

  task :deactivate_pax_token_economies => :environment do
    ActiveRecord::Base.logger = Logger.new STDOUT

    # Fetched stake currency id for PAX stake currency
    #
    # * Author: Ankit
    # * Date: 15/05/2019
    # * Reviewed By:
    #
    def fetch_stake_currency_id_for_pax
      @pax_stake_currency = StakeCurrency.where(symbol: 'PAX')

      unless @pax_stake_currency.first.present?
        fail "Invalid stake currency symbol"
      end

      @pax_stake_currency_id = @pax_stake_currency.first.id
    end

    # Function to set client related flags
    #
    # * Author: Ankit
    # * Date: 15/05/2019
    # * Reviewed By:
    #
    def change_client_related_flags
      fail if @client_ids_array.blank?
      clients = Client.where(id: @client_ids_array).all
      clients.each do |client|
        if GlobalConstant::Base.main_sub_environment?
          client.send("unset_#{GlobalConstant::Client.mainnet_test_economy_qr_code_uploaded_status}")
          client.send("unset_#{GlobalConstant::Client.mainnet_registered_in_mappy_server_status}")
        else
          client.send("unset_#{GlobalConstant::Client.sandbox_test_economy_qr_code_uploaded_status}")
          client.send("unset_#{GlobalConstant::Client.sandbox_registered_in_mappy_server_status}")
        end
        client.save!
      end
    end

    # Performs the required changes
    #
    # * Author: Ankit
    # * Date: 15/05/2019
    # * Reviewed By:
    #
    def perform_changes
      Token.where(stake_currency_id: @pax_stake_currency_id).find_in_batches(batch_size: 100) do |token_batches|
        @client_ids_array = []
        token_batches.each do |token|
          unless token['client_id'].present?
            fail 'invalid client id'
          end
          current_client_id = token['client_id']
          @client_ids_array.push(current_client_id)
          debug_data = {"disassociation_reason": "Removing all economies whose stake currency is PAX"}
          Token.where(client_id: current_client_id).update_all(client_id_was: current_client_id, client_id: nil, debug: debug_data.to_json)
          Workflow.where(client_id: current_client_id, kind: GlobalConstant::Workflow.token_deploy).update_all(unique_hash: nil)
        end

        change_client_related_flags
        KitSaasSharedCacheManagement::TokenDetails.new(@client_ids_array).clear
        CacheManagement::WorkflowByClient.new(@client_ids_array).clear
      end
    end

    # Deactivate PAX economy
    #
    # * Author: Ankit
    # * Date: 15/05/2019
    # * Reviewed By:
    #
    def deactivate_pax
      @pax_stake_currency.update_all(status: GlobalConstant::StakeCurrency.inactive_status)
    end

    # Perform
    #
    # * Author: Ankit
    # * Date: 15/05/2019
    # * Reviewed By:
    #
    def perform
      fetch_stake_currency_id_for_pax
      perform_changes
      deactivate_pax
    end

    perform

  end
end
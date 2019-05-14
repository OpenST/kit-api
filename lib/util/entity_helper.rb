module Util

  class EntityHelper

    class << self

      include Util::ResultHelper

      # All methods of this module are common methods which are used to fetch and validate entities

      # Fetch Client By Id
      #
      # * Author: Puneet
      # * Date: 09/10/2017
      # * Reviewed By: Sunil
      #
      # @param [Integer] client_id (mandatory) - client id
      #
      # @return [Result::Base]
      #
      def fetch_and_validate_client(client_id, err_prefix = 'u_eh_c')
        return client_not_found_response("#{err_prefix}:l_u_eh_fvc_1") if client_id.blank?
        client = CacheManagement::Client.new([client_id]).fetch[client_id]
        return client_not_found_response("#{err_prefix}:l_u_eh_fvc_2") if client.blank?
        success_with_data(client)
      end

      # Find & validate manager
      #
      # * Author: Puneet
      # * Date: 06/12/2018
      # * Reviewed By: Sunil
      #
      # @param [Integer] manager_id (mandatory) - manager id
      #
      # @return [Result::Base]
      #
      def fetch_and_validate_manager(manager_id, err_prefix = 'u_eh_m')
        return manager_not_found_response("#{err_prefix}:l_u_eh_fvm_1") if manager_id.blank?
        manager = CacheManagement::Manager.new([manager_id]).fetch[manager_id]
        return manager_not_found_response("#{err_prefix}:l_u_eh_fvm_2") if manager[:status] != GlobalConstant::Manager.active_status
        success_with_data(manager)
      end

      # Find & validate token
      #
      # * Author: Shlok
      # * Date: 21/01/2019
      # * Reviewed By: Sunil
      #
      # @param [Integer] client_id (mandatory) - client id
      #
      # @return [Result::Base]
      #
      def fetch_and_validate_token(client_id, err_prefix = 'u_eh_m')
        return client_not_found_response("#{err_prefix}:l_u_eh_fvt_1") if client_id.blank?
        token = KitSaasSharedCacheManagement::TokenDetails.new([client_id]).fetch[client_id]
        return token_not_found_response("#{err_prefix}:l_u_eh_fvt_2") if token.blank?

        token_id = token[:id]
        addresses_data = KitSaasSharedCacheManagement::TokenAddresses.new([token_id]).fetch

        if addresses_data[token_id][GlobalConstant::TokenAddresses.utility_branded_token_contract].present?
          token[:ubt_address] = addresses_data[token_id][GlobalConstant::TokenAddresses.utility_branded_token_contract][:address]
          token[:aux_chain_id] = addresses_data[token_id][GlobalConstant::TokenAddresses.utility_branded_token_contract][:deployed_chain_id].to_s
        end

        if token[:stake_currency_id]
          token[:stake_currency_symbol] = StakeCurrency.ids_to_details_cache[token[:stake_currency_id]][:symbol]
        end

        success_with_data(token)

      end

      # Find & validate ubt address for token
      #
      # * Author: Dhananjay
      # * Date: 09/04/2019
      # * Reviewed By:
      #
      # @param [Integer] token_id (mandatory) - token id
      #
      # @return [Result::Base]
      #
      def fetch_and_validate_ubt_address(token_id, err_prefix = 'u_eh_m')
        return token_not_found_response("#{err_prefix}:l_u_eh_fvua_1") if token_id.blank?
        addresses_data = KitSaasSharedCacheManagement::TokenAddresses.new([token_id]).fetch

        ubt_address = nil
        if addresses_data[token_id][GlobalConstant::TokenAddresses.utility_branded_token_contract].present?
          ubt_address = addresses_data[token_id][GlobalConstant::TokenAddresses.utility_branded_token_contract][:address]
        end
        success_with_data(ubt_address: ubt_address)
      end

      # Fetch chain Id for token id.
      #
      # * Author: Shlok
      # * Date: 05/03/2019
      # * Reviewed By: Sunil
      #
      # @param [Integer] token_id (mandatory) - token id
      #
      # @return [Result::Base]
      #
      def fetch_chain_id_for_token_id(token_id, err_prefix = 'u_eh_m')
        return token_not_found_response("#{err_prefix}:l_u_eh_fciti_1") if token_id.blank?
        token_addresses_data = KitSaasSharedCacheManagement::TokenAddresses.new([token_id]).fetch
        aux_chain_id = nil

        if token_addresses_data[token_id][GlobalConstant::TokenAddresses.utility_branded_token_contract].present?
          aux_chain_id = token_addresses_data[token_id][GlobalConstant::TokenAddresses.utility_branded_token_contract][:deployed_chain_id].to_s
        else
          return aux_chain_id_not_found_response("#{err_prefix}:l_u_eh_fciti_2")
        end
        success_with_data(aux_chain_id: aux_chain_id)
      end

      # Fetch stake currency details
      #
      # * Author: Anagha
      # * Date: 06/05/2019
      # * Reviewed By:
      #
      # @param [Integer] stake_currency_id (optional) - Stake currency id
      #
      # @return [Result::Base]
      #
      def fetch_stake_currency_details(stake_currency_id = nil)
        stake_currencies_details = {}
        cache_data = StakeCurrency.ids_to_details_cache

        if stake_currency_id.present?
          stake_currencies_details[cache_data[stake_currency_id][:symbol]] = cache_data[stake_currency_id]
          return success_with_data(stake_currencies_details)
        end

        cache_data.each do |id, row_value|
          stake_currencies_details[row_value[:symbol]] = row_value
        end

        success_with_data(stake_currencies_details)
      end

      private
      
      # no client associated response
      #
      # * Author: Puneet
      # * Date: 15/01/2018
      # * Reviewed By: Sunil
      #
      # @param [String] err (mandatory) - err code
      #
      # @return [Result::Base]
      #
      def client_not_found_response(err)
        error_with_data(
            err,
            'client_not_found',
            GlobalConstant::ErrorAction.default
        )
      end

      # No manager found
      #
      # * Author: Puneet
      # * Date: 15/01/2018
      # * Reviewed By: Sunil
      #
      # @param [String] err (mandatory) - err code
      #
      # @return [Result::Base]
      #
      def manager_not_found_response(err)
        error_with_data(
            err,
            'manager_not_found',
            GlobalConstant::ErrorAction.default
        )
      end

      # No token found
      #
      # * Author: Shlok
      # * Date: 21/01/2019
      # * Reviewed By: Sunil
      #
      # @param [String] err (mandatory) - err code
      #
      # @return [Result::Base]
      #
      def token_not_found_response(err)
        error_with_data(
            err,
            'token_not_found',
            GlobalConstant::ErrorAction.default
        )
      end

      # No stake currency id found
      #
      # * Author: Dhananjay
      # * Date: 21/01/2019
      # * Reviewed By: Anagha
      #
      # @param [String] err (mandatory) - err code
      #
      # @return [Result::Base]
      #
      def stake_currency_id_not_found_response(err)
        error_with_data(
          err,
          'stake_currency_id_not_found',
          GlobalConstant::ErrorAction.default
        )
      end

      # No token found
      #
      # * Author: Shlok
      # * Date: 06/03/2019
      # * Reviewed By: Sunil
      #
      # @param [String] err (mandatory) - err code
      #
      # @return [Result::Base]
      #
      def aux_chain_id_not_found_response(err)
        error_with_data(
          err,
          'aux_chain_id_not_found',
          GlobalConstant::ErrorAction.default
        )
      end
      
    end

  end

end

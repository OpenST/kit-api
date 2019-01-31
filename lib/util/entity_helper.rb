module Util

  class EntityHelper

    class << self

      include Util::ResultHelper

      # All methods of this module are common methods which are used to fetch and validate entities

      # Fetch Client By Id
      #
      # * Author: Puneet
      # * Date: 09/10/2017
      # * Reviewed By:
      #
      # @return [Hash]
      #
      def fetch_and_validate_client(client_id, err_prefix = 'u_eh_c')
        client_not_found_response("#{err_prefix}:l_u_eh_fvc_1") if client_id.blank?
        client = CacheManagement::Client.new([client_id]).fetch[client_id]
        client_not_found_response("#{err_prefix}:l_u_eh_fvc_2") if client.blank?
        client
      end

      # Find & validate manager
      #
      # * Author: Puneet
      # * Date: 06/12/2018
      # * Reviewed By:
      #
      # @return [Hash]
      #
      def fetch_and_validate_manager(manager_id, err_prefix = 'u_eh_m')
        return manager_not_found_response("#{err_prefix}:l_u_eh_fvm_1") if manager_id.blank?
        manager = CacheManagement::Manager.new([manager_id]).fetch[manager_id]
        return manager_not_found_response("#{err_prefix}:l_u_eh_fvm_2") if manager[:status] != GlobalConstant::Manager.active_status
        manager
      end

      # Find & validate token
      #
      # * Author: Shlok
      # * Date: 21/01/2019
      # * Reviewed By:
      #
      # @return [Hash]
      #
      def fetch_and_validate_token(client_id, err_prefix = 'u_eh_m')
        return token_not_found_response("#{err_prefix}:l_u_eh_fvt_1") if client_id.blank?
        token = KitSaasSharedCacheManagement::TokenDetails.new([client_id]).fetch[client_id]
        return token_not_found_response("#{err_prefix}:l_u_eh_fvt_2") if token.blank?
        success_with_data(token)
      end

      #TODO: Discuss about the following below private methods.
      #private
      
      # no client associated response
      #
      # * Author: Puneet
      # * Date: 15/01/2018
      # * Reviewed By:
      #
      # @param [String] err (mandatory) - err code
      #
      # @return [Result::Base]
      #
      def client_not_found_response(err)
        fail OstCustomError.new error_with_data(
                                    err,
                                    'client_not_found',
                                    GlobalConstant::ErrorAction.default
                                )
      end

      # no client associated response
      #
      # * Author: Puneet
      # * Date: 15/01/2018
      # * Reviewed By:
      #
      # @param [String] err (mandatory) - err code
      #
      # @return [Result::Base]
      #
      def client_inactive_response(err)
        fail OstCustomError.new error_with_data(
                                    err,
                                    'client_inactive',
                                    GlobalConstant::ErrorAction.default
                                )
      end

      # No manager found
      #
      # * Author: Puneet
      # * Date: 15/01/2018
      # * Reviewed By:
      #
      # @param [String] err (mandatory) - err code
      #
      # @return [Result::Base]
      #
      def manager_not_found_response(err)
        fail OstCustomError.new error_with_data(
                                    err,
                                    'manager_not_found',
                                    GlobalConstant::ErrorAction.default
                                )
      end

      # Manager inactive response
      #
      # * Author: Puneet
      # * Date: 15/01/2018
      # * Reviewed By:
      #
      # @param [String] err (mandatory) - err code
      #
      # @return [Result::Base]
      #
      def manager_inactive_response(err)
        fail OstCustomError.new error_with_data(
                                    err,
                                    'manager_inactive',
                                    GlobalConstant::ErrorAction.default
                                )
      end

      # No token found
      #
      # * Author: Shlok
      # * Date: 21/01/2019
      # * Reviewed By:
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

      #  Client manager not associated response
      #
      # * Author: Puneet
      # * Date: 15/01/2018
      # * Reviewed By:
      #
      # @param [String] err (mandatory) - err code
      #
      # @return [Result::Base]
      #
      def client_manager_not_associated_response(err)
        fail OstCustomError.new error_with_data(
                                    err,
                                    'client_manager_inactive',
                                    GlobalConstant::ErrorAction.default
                                )
      end
      
    end

  end

end

module Util

  class EntityHelper

    class << self

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
        client_not_found_response("#{err_prefix}_1") if client_id.blank?
        client = CacheManagement::Client.new([client_id]).fetch[client_id]
        client_not_found_response("#{err_prefix}_2") if client.blank?
        if Util::CommonValidator.is_mainnet_env?
          client_inactive_response("#{err_prefix}_3") if client[:mainnet_statuses].include?(GlobalConstant::Client.mainnet_inactive_status)
        else
          client_inactive_response("#{err_prefix}_4") if client[:sandbox_statuses].include?(GlobalConstant::Client.sandbox_inactive_status)
        end
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
        manager_not_found_response("#{err_prefix}_1") if manager_id.blank?
        manager = CacheManagement::Manager.new([manager_id]).fetch[manager_id]
        manager_not_found_response("#{err_prefix}_2") if manager[:status] != GlobalConstant::Manager.active_status
        success
      end

      private
      
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

      # no manager found
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

      # manager inactive response
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

      #  client manager not associated response
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

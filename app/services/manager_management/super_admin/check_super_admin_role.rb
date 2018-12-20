module ManagerManagement

  module SuperAdmin

    class CheckSuperAdminRole < ServicesBase

      # Initialize
      #
      # * Author: Shlok
      # * Date: 12/12/2018
      # * Reviewed By:
      #
      # @params [Integer] client_manager (mandatory) - client manager object
      #
      # @return [ManagerManagement::SuperAdmin::CheckSuperAdminRole]
      #
      def initialize(params)
        super

        @client_manager = params[:client_manager]

      end

      # Perform
      #
      # * Author: Shlok
      # * Date: 12/12/2018
      # * Reviewed By:
      #
      # @return [Result::Base]
      #
      def perform

        handle_errors_and_exceptions do

          verify_super_admin_role

          success_with_data({})

        end

      end

      private

      # Check if Super Admin role
      #
      # * Author: Shlok
      # * Date: 12/12/2018
      # * Reviewed By:
      #
      # @return [Result::Base]
      #
      def verify_super_admin_role

        fail OstCustomError.new error_with_data(
                                  'mm_sa_vsa_1',
                                  'unauthorized_access_response',
                                  GlobalConstant::ErrorAction.default
                                ) if @client_manager.blank?

        fail OstCustomError.new error_with_data(
                                  'mm_sa_vsa_2',
                                  'unauthorized_access_response',
                                  GlobalConstant::ErrorAction.default
                                ) if @client_manager[:privileges].exclude?(GlobalConstant::ClientManager.is_super_admin_privilege)

        success

      end

    end

  end

end

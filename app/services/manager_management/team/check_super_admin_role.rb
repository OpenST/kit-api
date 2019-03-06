module ManagerManagement

  module Team

    class CheckSuperAdminRole < ServicesBase

      # Initialize
      #
      # * Author: Shlok
      # * Date: 12/12/2018
      # * Reviewed By:
      #
      # @params [Integer] client_manager (mandatory) - client manager object
      #
      # @return [ManagerManagement::Team::CheckSuperAdminRole]
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

          r = verify_super_admin_role
          return r unless r.success?

          success

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

        return error_with_data(
          'mm_sa_vsa_1',
          'unauthorized_access_response',
          GlobalConstant::ErrorAction.default
        ) if @client_manager.blank?

        return error_with_data(
          'mm_sa_vsa_2',
          'email_inactive',
          GlobalConstant::ErrorAction.default
        ) if @client_manager[:privileges].include?(GlobalConstant::ClientManager.has_been_deleted_privilege)

        return error_with_data(
          'mm_sa_vsa_3',
          'unauthorized_access_response',
          GlobalConstant::ErrorAction.default
        ) if @client_manager[:privileges].exclude?(GlobalConstant::ClientManager.is_super_admin_privilege)

        success

      end

    end

  end

end

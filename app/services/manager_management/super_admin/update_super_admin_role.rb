module ManagerManagement

  module SuperAdmin

    class UpdateSuperAdminRole < ServicesBase

      # Initialize
      #
      # * Author: Puneet
      # * Date: 06/12/2018
      # * Reviewed By:
      #
      # @params [Integer] manager_id (mandatory) - id of the manager who is deleting this admin
      # @params [Integer] client_id (mandatory) - id of the client who is deleting this admin
      # @params [String] to_update_client_manager_id (mandatory) - id of the client_manager who is to be updated
      # @params [Integer] is_super_admin (mandatory) - value to be set to. 1 => set, 0 => unset
      #
      # @return [ManagerManagement::SuperAdmin::UpdateSuperAdminRole]
      #
      def initialize(params)

        super

        @to_update_client_manager_id = @params[:to_update_client_manager_id]
        @manager_id = @params[:manager_id]
        @client_id = @params[:client_id]
        @is_super_admin = @params[:is_super_admin]

        @manager_to_be_updated_obj = nil
        @to_update_client_manager = nil

      end

      # Perform
      #
      # * Author: Puneet
      # * Date: 06/12/2018
      # * Reviewed By:
      #
      # @return [Result::Base]
      #
      def perform

        handle_errors_and_exceptions do

          r = validate_and_sanitize
          return r unless r.success?

          r = fetch_client_manager
          return r unless r.success?

          r = fetch_manager_to_be_updated
          return r unless r.success?

          r = validate_client_manager_privilege
          return r unless r.success?

          r = update_client_manager
          return r unless r.success?

          success_with_data({
              result_type: result_type,
              result_type => [
                @to_update_client_manager.formated_cache_data
              ],
              managers: {
                  @manager_to_be_updated_obj.id => @manager_to_be_updated_obj.formated_cache_data
              }
          })

        end

      end

      private

      # Validate
      #
      # * Author: Puneet
      # * Date: 15/01/2018
      # * Reviewed By:
      #
      # @return [Result::Base]
      #
      def validate_and_sanitize

        # NOTE: To be on safe side, check for generic errors as well
        r = validate
        return r unless r.success?

        validation_errors = []

        validation_errors.push('invalid_is_super_admin') unless Util::CommonValidator.is_boolean_string?(@is_super_admin)

        return validation_error(
          'mm_sa_usar_1',
          'invalid_api_params',
          validation_errors,
          GlobalConstant::ErrorAction.default
        ) if validation_errors.present?

        success

      end

      # Fetch manager to be deleted
      #
      # * Author: Puneet
      # * Date: 15/01/2018
      # * Reviewed By:
      #
      # @return [Result::Base]
      #
      def fetch_manager_to_be_updated

        @manager_to_be_updated_obj = Manager.where(id: @to_update_client_manager.manager_id).first

        return validation_error(
            'mm_sa_usar_2',
            'resource_not_found',
            [],
            GlobalConstant::ErrorAction.default
        ) if @manager_to_be_updated_obj.blank?

        return validation_error(
            'mm_sa_usar_3',
            'invalid_api_params',
            ['to_update_client_manager_id_inactive'],
            GlobalConstant::ErrorAction.default
        ) if @manager_to_be_updated_obj.status != GlobalConstant::Manager.active_status

        success

      end

      # Fetch client manager
      #
      # * Author: Puneet
      # * Date: 06/12/2018
      # * Reviewed By:
      #
      # @return [Result::Base]
      #
      def fetch_client_manager

        @to_update_client_manager = ClientManager.where(id: @to_update_client_manager_id).first

        return validation_error(
          'mm_sa_usar_4',
          'resource_not_found',
          [],
          GlobalConstant::ErrorAction.default
        ) if @to_update_client_manager.blank?

        return validation_error(
          'mm_sa_usar_5',
          'unauthorized_access_response',
          [],
          GlobalConstant::ErrorAction.default
        ) if @to_update_client_manager.client_id != @client_id || @to_update_client_manager.manager_id == @manager_id

        success

      end

      # Validate client manager's existing privileges.
      #
      # * Author: Shlok
      # * Date: 09/01/2019
      # * Reviewed By:
      #
      # @return [Result::Base]
      #
      def validate_client_manager_privilege

        privileges = ClientManager.get_bits_set_for_privileges(@to_update_client_manager.privileges)

        if Util::CommonValidator.is_true_boolean_string?(@is_super_admin)
          # if trying to set a super admin as super admin.
          return validation_error(
            'mm_sa_usar_6',
            'already_super_admin',
            [],
            GlobalConstant::ErrorAction.default
          ) if privileges.include?(GlobalConstant::ClientManager.is_super_admin_privilege)

        else
          # if trying to set an admin as admin.
          return validation_error(
            'mm_sa_usar_7',
            'already_admin',
            [],
            GlobalConstant::ErrorAction.default
          ) if privileges.include?(GlobalConstant::ClientManager.is_admin_privilege)

        end

        success

      end

      # Update client manager
      #
      # * Author: Puneet
      # * Date: 06/12/2018
      # * Reviewed By:
      #
      # @return [Result::Base]
      #
      def update_client_manager

        if Util::CommonValidator.is_true_boolean_string?(@is_super_admin)
          @to_update_client_manager.send("unset_#{GlobalConstant::ClientManager.is_admin_privilege}")
          @to_update_client_manager.send("set_#{GlobalConstant::ClientManager.is_super_admin_privilege}")
        else
          @to_update_client_manager.send("unset_#{GlobalConstant::ClientManager.is_super_admin_privilege}")
          @to_update_client_manager.send("set_#{GlobalConstant::ClientManager.is_admin_privilege}")
        end

        @to_update_client_manager.save!

        success

      end

      def result_type
        :client_managers
      end

    end

  end

end
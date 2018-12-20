module ManagerManagement

  module SuperAdmin

    class DeleteAdmin < ServicesBase

      # Initialize
      #
      # * Author: Puneet
      # * Date: 06/12/2018
      # * Reviewed By:
      #
      # @param [Integer] manager_id (mandatory) - id of the manager who is deleting this admin
      # @param [Integer] client_id (mandatory) - id of the client who is deleting this admin
      # @param [Integer] to_update_client_manager_id (mandatory) - id of the client_manager which is to be deleted
      #
      # @return [ManagerManagement::SuperAdmin::DeleteAdmin]
      #
      def initialize(params)

        super

        @to_update_client_manager_id = @params[:to_update_client_manager_id]
        @manager_id = @params[:manager_id]
        @client_id = @params[:client_id]

        @manager_to_be_deleted_obj = nil
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

          validate_and_sanitize

          fetch_client_manager

          fetch_manager_to_be_deleted

          update_client_manager

          update_manager

          success_with_data({
            result_type: result_type,
            result_type => [
              @to_update_client_manager.formated_cache_data
            ],
            managers: {
              @manager_to_be_deleted_obj.id => @manager_to_be_deleted_obj.formated_cache_data
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
        validate

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

        fail OstCustomError.new validation_error(
                                    'mm_su_dm_2',
                                    'resource_not_found',
                                    [],
                                    GlobalConstant::ErrorAction.default
                                ) if @to_update_client_manager.blank?

        fail OstCustomError.new validation_error(
                                    'mm_su_dm_2',
                                    'unauthorized_access_response',
                                    [],
                                    GlobalConstant::ErrorAction.default
                                ) if @to_update_client_manager.client_id != @client_id || @to_update_client_manager.manager_id == @manager_id ||
            @to_update_client_manager.send("#{GlobalConstant::ClientManager.is_super_admin_privilege}?")

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
      def fetch_manager_to_be_deleted

        @manager_to_be_deleted_obj = Manager.where(id: @to_update_client_manager.manager_id).first

        fail OstCustomError.new validation_error(
                                    'mm_su_dm_1',
                                    'resource_not_found',
                                    [],
                                    GlobalConstant::ErrorAction.default
                                ) if @manager_to_be_deleted_obj.blank?

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

        @to_update_client_manager.send("unset_#{GlobalConstant::ClientManager.is_admin_privilege}")
        @to_update_client_manager.send("unset_#{GlobalConstant::ClientManager.is_invited_privilege}")
        @to_update_client_manager.send("unset_#{GlobalConstant::ClientManager.has_rejected_invite_privilege}")
        @to_update_client_manager.send("set_#{GlobalConstant::ClientManager.has_been_deleted_privilege}")

        @to_update_client_manager.save!

        success

      end

      # Update client
      #
      # * Author: Puneet
      # * Date: 06/12/2018
      # * Reviewed By:
      #
      # @return [Result::Base]
      #
      def update_manager

        @manager_to_be_deleted_obj.current_client_id = nil

        @manager_to_be_deleted_obj.save!

        success

      end

      def result_type
        :client_managers
      end

    end

  end

end
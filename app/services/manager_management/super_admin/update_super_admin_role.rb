module ManagerManagement

  module SuperAdmin

    class UpdateSuperAdminRole < ServicesBase

      # Initialize
      #
      # * Author: Puneet
      # * Date: 06/12/2018
      # * Reviewed By:
      #
      # @param [Integer] manager_id (mandatory) - id of the manager who is deleting this admin
      # @param [Integer] client_id (mandatory) - id of the client who is deleting this admin
      # @param [String] to_update_client_manager_id (mandatory) - id of the client_manager who is to be updated
      # @param [Integer] is_super_admin (mandatory) - value to be set to. 1 => set, 0 => unset
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

          validate_and_sanitize

          fetch_client_manager

          fetch_manager_to_be_updated

          update_client_manager

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

        validation_errors = []

        validation_errors.push('invalid_is_super_admin') unless Util::CommonValidator.is_boolean_string?(@is_super_admin)

        fail OstCustomError.new validation_error(
                                    'mm_sa_usar_1',
                                    'invalid_api_params',
                                    validation_errors,
                                    GlobalConstant::ErrorAction.default
                                ) if validation_errors.present?

        # NOTE: To be on safe side, check for generic errors as well
        validate

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

        fail OstCustomError.new validation_error(
                                    'mm_sa_usar_2',
                                    'resource_not_found',
                                    [],
                                    GlobalConstant::ErrorAction.default
                                ) if @manager_to_be_updated_obj.blank?

        fail OstCustomError.new validation_error(
                                    'mm_sa_usar_3',
                                    'invalid_api_params',
                                    ['to_update_client_manager_id_inactive'],
                                    GlobalConstant::ErrorAction.default
                                ) if @manager_to_be_updated_obj.status != GlobalConstant::Manager.active_status

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
                                    'mm_sa_usar_4',
                                    'resource_not_found',
                                    [],
                                    GlobalConstant::ErrorAction.default
                                ) if @to_update_client_manager.blank?

        fail OstCustomError.new validation_error(
                                    'mm_sa_usar_5',
                                    'unauthorized_access_response',
                                    [],
                                    GlobalConstant::ErrorAction.default
                                ) if @to_update_client_manager.client_id != @client_id || @to_update_client_manager.manager_id == @manager_id

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
          @to_update_client_manager.send("set_#{GlobalConstant::ClientManager.is_super_admin_privilege}")
        else
          @to_update_client_manager.send("unset_#{GlobalConstant::ClientManager.is_super_admin_privilege}")
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
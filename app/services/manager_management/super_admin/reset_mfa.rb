module ManagerManagement

  module SuperAdmin

    class ResetMfa < ServicesBase

      # Initialize
      #
      # * Author: Puneet
      # * Date: 03/05/2018
      # * Reviewed By:
      #
      # @param [Integer] manager_id (mandatory) - id of the manager who is deleting this admin
      # @param [Integer] client_id (mandatory) - id of the client who is deleting this admin
      # @param [Integer] to_update_client_manager_id (mandatory) - id of manager whose MFA has to be set
      #
      # @return [ManagerManagement::SuperAdmin::ResetMfa]
      #
      def initialize(params)
        super
        @manager_id = @params[:manager_id]
        @client_id = @params[:client_id]
        @to_update_client_manager_id = @params[:to_update_client_manager_id]
        @to_update_client_manager = nil
        @to_update_manager_obj = nil
      end

      # Perform
      #
      # * Author: Puneet
      # * Date: 03/05/2018
      # * Reviewed By:
      #
      # @return [Result::Base]
      #
      def perform

        handle_errors_and_exceptions do

          validate_and_sanitize

          fetch_client_manager

          fetch_manager

          reset_mfa

          success_with_data({
            result_type: result_type,
            result_type => [
              @to_update_client_manager.formated_cache_data
            ],
            managers: {
                @to_update_manager_obj.id => @to_update_manager_obj.formated_cache_data
            }
          })

        end

      end

      private

      # Validate and sanitize
      #
      # * Author: Puneet
      # * Date: 06/12/2018
      # * Reviewed By:
      #
      # @return [Result::Base]
      #
      def validate_and_sanitize
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
                                    'mm_su_rm_2',
                                    'resource_not_found',
                                    [],
                                    GlobalConstant::ErrorAction.default
                                ) if @to_update_client_manager.blank?

        fail OstCustomError.new validation_error(
                                    'mm_su_rm_3',
                                    'unauthorized_access_response',
                                    [],
                                    GlobalConstant::ErrorAction.default
                                ) if @to_update_client_manager.client_id != @client_id || @to_update_client_manager.manager_id == @manager_id

        success

      end

      # Validate and sanitize
      #
      # * Author: Puneet
      # * Date: 06/12/2018
      # * Reviewed By:
      #
      # @return [Result::Base]
      #
      def fetch_manager

        @to_update_manager_obj = Manager.where(id: @to_update_client_manager.manager_id).first
        fail OstCustomError.new unauthorized_access_response('mm_sa_rm_2') if @to_update_manager_obj.blank?
        success

      end

      # Resets MFA token of admin
      #
      # * Author: Puneet
      # * Date: 03/05/2018
      # * Reviewed By:
      #
      # @return [Result::Base]
      #
      def reset_mfa

        @to_update_manager_obj.mfa_token = nil
        @to_update_manager_obj.send("unset_#{GlobalConstant::Manager.has_setup_mfa_property}")
        @to_update_manager_obj.last_session_updated_at = current_timestamp
        @to_update_manager_obj.save!

        success

      end

      def result_type
        :client_managers
      end

    end

  end

end

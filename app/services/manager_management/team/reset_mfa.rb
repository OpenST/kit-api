module ManagerManagement

  module Team

    class ResetMfa < ServicesBase

      # Initialize
      #
      # * Author: Puneet
      # * Date: 03/05/2018
      # * Reviewed By: Sunil
      #
      # @params [Integer] manager_id (mandatory) - id of the manager who is deleting this admin
      # @params [Integer] client_id (mandatory) - id of the client who is deleting this admin
      # @params [Integer] to_update_client_manager_id (mandatory) - id of manager whose MFA has to be set
      # @params [Hash] client_manager (mandatory) - logged in client manager object
      #
      # @return [ManagerManagement::Team::ResetMfa]
      #
      def initialize(params)
        super

        @manager_id = @params[:manager_id]
        @client_id = @params[:client_id]
        @to_update_client_manager_id = @params[:to_update_client_manager_id]
        @client_manager = @params[:client_manager]

        @to_update_client_manager = nil
        @to_update_manager_obj = nil
      end

      # Perform
      #
      # * Author: Puneet
      # * Date: 03/05/2018
      # * Reviewed By: Sunil
      #
      # @return [Result::Base]
      #
      def perform

        handle_errors_and_exceptions do

          r = validate_and_sanitize
          return r unless r.success?

          r = fetch_client_manager
          return r unless r.success?

          r = fetch_manager
          return r unless r.success?

          r = reset_mfa
          return r unless r.success?

          success_with_data({
            result_type: result_type,
            result_type => [
              @to_update_client_manager.formatted_cache_data
            ],
            managers: {
                @to_update_manager_obj.id => @to_update_manager_obj.formatted_cache_data
            }
          })

        end

      end

      private

      # Validate and sanitize
      #
      # * Author: Puneet
      # * Date: 06/12/2018
      # * Reviewed By: Sunil
      #
      # @return [Result::Base]
      #
      def validate_and_sanitize
        r = validate
        return r unless r.success?

        success
      end

      # validate
      #
      # * Author: Kedar
      # * Date: 22/02/2019
      # * Reviewed By: Puneet
      #
      # @return [Result::Base]
      #
      def validate
        r = super
        return r unless r.success?

        r = ManagerManagement::Team::CheckSuperAdminRole.new(
          {client_manager: @client_manager}).perform

        unless r.success?
          return error_with_data(
            's_mm_sa_rm_1',
            'unauthorized_to_perform_action',
            GlobalConstant::ErrorAction.default
          )
        end

        success
      end

      # Fetch client manager
      #
      # * Author: Puneet
      # * Date: 06/12/2018
      # * Reviewed By: Sunil
      #
      # @return [Result::Base]
      #
      def fetch_client_manager

        @to_update_client_manager = ClientManager.where(id: @to_update_client_manager_id).first

        return validation_error(
          's_mm_sa_rm_2',
          'resource_not_found',
          [],
          GlobalConstant::ErrorAction.default
        ) if @to_update_client_manager.blank?

        return validation_error(
          's_mm_sa_rm_3',
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
      # * Reviewed By: Sunil
      #
      # @return [Result::Base]
      #
      def fetch_manager

        @to_update_manager_obj = Manager.where(id: @to_update_client_manager.manager_id).first
        return validation_error(
          's_mm_sa_rm_4',
          'unauthorized_access_response',
          [],
          GlobalConstant::ErrorAction.default
        ) if @to_update_manager_obj.blank?

        success

      end

      # Resets MFA token of admin
      #
      # * Author: Puneet
      # * Date: 03/05/2018
      # * Reviewed By: Sunil
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

      # Result type
      #
      # * Author: Puneet
      # * Date: 03/05/2018
      # * Reviewed By: Sunil
      #
      # @return [Symbol]
      #
      def result_type
        :client_managers
      end

    end

  end

end

module ManagerManagement

  module Team

    class DeleteAdmin < ServicesBase

      # Initialize
      #
      # * Author: Puneet
      # * Date: 06/12/2018
      # * Reviewed By: Sunil
      #
      # @params [Integer] manager_id (mandatory) - id of the manager who is deleting this admin
      # @params [Integer] client_id (mandatory) - id of the client who is deleting this admin
      # @params [Integer] to_update_client_manager_id (mandatory) - id of the client_manager which is to be deleted
      # @params [Hash] client_manager (mandatory) - logged in client manager object
      #
      # @return [ManagerManagement::Team::DeleteAdmin]
      #
      def initialize(params)
        super

        @to_update_client_manager_id = @params[:to_update_client_manager_id]
        @manager_id = @params[:manager_id]
        @client_id = @params[:client_id]
        @client_manager = @params[:client_manager]

        @manager_to_be_deleted_obj = nil
        @to_update_client_manager = nil
      end

      # Perform
      #
      # * Author: Puneet
      # * Date: 06/12/2018
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

          r = fetch_manager_to_be_deleted
          return r unless r.success?

          if @manager_to_be_deleted_obj.status == GlobalConstant::Manager.invited_status
            r = reject_invites
            return r unless r.success?
          end

          r = update_client_manager
          return r unless r.success?

          r = update_manager
          return r unless r.success?

          r = reset_custom_attributes
          return r unless r.success?

          r = remove_user_from_campaign
          return r unless r.success?

          success_with_data({
            result_type: result_type,
            result_type => [
              @to_update_client_manager.formatted_cache_data
            ],
            managers: {
              @manager_to_be_deleted_obj.id => @manager_to_be_deleted_obj.formatted_cache_data
            }
          })

        end

      end

      private

      # Validate
      #
      # * Author: Puneet
      # * Date: 15/01/2018
      # * Reviewed By: Sunil
      #
      # @return [Result::Base]
      #
      def validate_and_sanitize

        # NOTE: To be on safe side, check for generic errors as well
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
            's_mm_sa_da_1',
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
          's_mm_sa_da_2',
          'resource_not_found',
          [],
          GlobalConstant::ErrorAction.default
        ) if @to_update_client_manager.blank?

        return validation_error(
          's_mm_sa_da_3',
          'unauthorized_access_response',
          [],
          GlobalConstant::ErrorAction.default
        ) if @to_update_client_manager.client_id != @client_id || @to_update_client_manager.manager_id == @manager_id

        success

      end

      # Fetch manager to be deleted
      #
      # * Author: Puneet
      # * Date: 15/01/2018
      # * Reviewed By: Sunil
      #
      # @return [Result::Base]
      #
      def fetch_manager_to_be_deleted

        @manager_to_be_deleted_obj = Manager.where(id: @to_update_client_manager.manager_id).first

        return validation_error(
          's_mm_sa_da_4',
          'resource_not_found',
          [],
          GlobalConstant::ErrorAction.default
        ) if @manager_to_be_deleted_obj.blank?

        success
      end

      # Reject invite tokens for the manager if its status is invited.
      #
      # * Author: Shlok
      # * Date: 08/01/2019
      # * Reviewed By: Sunil
      #
      # @return [Result::Base]
      #
      def reject_invites

        kinds = [GlobalConstant::ManagerValidationHash.manager_invite_kind,
                 GlobalConstant::ManagerValidationHash.double_optin_kind,
                 GlobalConstant::ManagerValidationHash.reset_password_kind]

          # Mark any other active invite token (s) for this manager as inactive
          ManagerValidationHash.where(
            manager_id: @manager_to_be_deleted_obj.id,
            kind: kinds,
            status: GlobalConstant::ManagerValidationHash.active_status
          ).update_all(
            status: GlobalConstant::ManagerValidationHash.inactive_status
          )

          success
      end

      # Update client manager
      #
      # * Author: Puneet
      # * Date: 06/12/2018
      # * Reviewed By: Sunil
      #
      # @return [Result::Base]
      #
      def update_client_manager

        if @manager_to_be_deleted_obj.status == GlobalConstant::Manager.invited_status
          @to_update_client_manager.destroy!
          # We are completely deleting the entry from the database if the user is only invited.
        else
          @to_update_client_manager.send("set_#{GlobalConstant::ClientManager.has_been_deleted_privilege}")
          @to_update_client_manager.save!
          # We are marking that the admin has been deleted.
        end

        success

      end

      # Update client
      #
      # * Author: Puneet
      # * Date: 06/12/2018
      # * Reviewed By: Sunil
      #
      # @return [Result::Base]
      #
      def update_manager

        if @manager_to_be_deleted_obj.status == GlobalConstant::Manager.invited_status
          @manager_to_be_deleted_obj.destroy!
          # We are completely deleting the entry from the database if the user is only invited.
        end

        # We are not doing anything if the admin was active because we need to store the information for future.

        success

      end

      # Remove user from platform users campaign
      #
      # * Author: Santhosh
      # * Date: 26/07/2019
      # * Reviewed By:
      #
      # @return [Result::Base]
      #
      def reset_custom_attributes
        attributes_hash = {}

        GlobalConstant::PepoCampaigns.delete_admin_attributes.each do |attribute|
          attributes_hash[attribute] = nil
        end

        Email::HookCreator::UpdateContact.new(
            receiver_entity_id: @manager_to_be_deleted_obj[:id],
            receiver_entity_kind: GlobalConstant::EmailServiceApiCallHook.manager_receiver_entity_kind,
            custom_attributes: attributes_hash
        ).perform

        success
      end

      # Remove user from platform users campaign
      #
      # * Author: Santhosh
      # * Date: 26/07/2019
      # * Reviewed By:
      #
      # @return [Result::Base]
      #
      def remove_user_from_campaign
        Email::HookCreator::RemoveContact.new(
            receiver_entity_id: 0,
            receiver_entity_kind: GlobalConstant::EmailServiceApiCallHook.specific_email_receiver_entity_kind,
            receiver_email: @manager_to_be_deleted_obj[:email],
            list_id: GlobalConstant::PepoCampaigns.platform_users_list_id
        ).perform

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
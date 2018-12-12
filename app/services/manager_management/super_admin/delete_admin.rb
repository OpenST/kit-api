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
      # @param [Integer] client_manager_id (mandatory) - id of the client_manager which is to be deleted
      #
      # @return [ManagerManagement::SuperAdmin::DeleteAdmin]
      #
      def initialize(params)

        super

        @client_manager_id = @params[:client_manager_id]
        @manager_id = @params[:manager_id]
        @client_id = @params[:client_id]

        @client_manager = nil

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

          update_client_manager

          update_manager

          success_with_data({})

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

        @client_manager_id = @client_manager_id.to_i

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

        @client_manager = ClientManager.where(id: @client_manager_id).first

        fail OstCustomError.new validation_error(
                                    'mm_su_dm_1',
                                    'resource_not_found',
                                    [],
                                    GlobalConstant::ErrorAction.default
                                ) if @client_manager.blank?

        fail OstCustomError.new validation_error(
                                    'mm_su_dm_2',
                                    'unauthorized_access_response',
                                    [],
                                    GlobalConstant::ErrorAction.default
                                ) if @client_manager.manager_id == @manager_id ||
            @client_manager.send("#{GlobalConstant::ClientManager.is_super_admin_privilage}?")

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

        @client_manager.send("unset_#{GlobalConstant::ClientManager.is_admin_privilage}")
        @client_manager.send("unset_#{GlobalConstant::ClientManager.is_invited_privilage}")
        @client_manager.send("set_#{GlobalConstant::ClientManager.has_been_deleted_privilage}")

        @client_manager.save!

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

        manager = Manager.where(id: @manager_id).first

        manager.current_client_id = nil

        manager.save!

        success

      end

    end

  end

end
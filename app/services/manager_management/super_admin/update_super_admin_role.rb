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
      # @param [String] email (mandatory) - email of the client_manager who is to be updated
      # @param [Integer] is_super_admin (mandatory) - value to be set to. 1 => set, 0 => unset
      #
      # @return [ManagerManagement::SuperAdmin::UpdateSuperAdminRole]
      #
      def initialize(params)

        super

        @email = @params[:email]
        @manager_id = @params[:manager_id]
        @client_id = @params[:client_id]
        @is_super_admin = @params[:is_super_admin]

        @manager_to_be_updated_obj = nil
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

          fetch_manager_to_be_updated

          fetch_client_manager

          update_client_manager

          success_with_data({})

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

        @email = @email.to_s.downcase.strip
        validation_errors.push('invalid_email') unless Util::CommonValidator.is_valid_email?(@email)
        validation_errors.push('invalid_is_super_admin') unless Util::CommonValidator.is_boolean_string?(@is_super_admin)

        fail OstCustomError.new validation_error(
                                    'mm_sa_utsar_1',
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

        @manager_to_be_updated_obj = Manager.where(email: @email).first

        fail OstCustomError.new validation_error(
                                    'mm_sa_utsar_2',
                                    'resource_not_found',
                                    [],
                                    GlobalConstant::ErrorAction.default
                                ) if @manager_to_be_updated_obj.blank?

        fail OstCustomError.new validation_error(
                                    'mm_sa_utsar_3',
                                    'invalid_api_params',
                                    ['email_inactive'],
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

        @client_manager = ClientManager.where(client_id: @client_id, manager_id: @manager_to_be_updated_obj.id).first

        fail OstCustomError.new validation_error(
                                    'mm_sa_utsar_4',
                                    'resource_not_found',
                                    [],
                                    GlobalConstant::ErrorAction.default
                                ) if @client_manager.blank?

        fail OstCustomError.new validation_error(
                                    'mm_sa_utsar_5',
                                    'unauthorized_access_response',
                                    [],
                                    GlobalConstant::ErrorAction.default
                                ) if @client_manager.manager_id == @manager_id

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
          @client_manager.send("set_#{GlobalConstant::ClientManager.is_super_admin_privilege}")
        else
          @client_manager.send("unset_#{GlobalConstant::ClientManager.is_super_admin_privilege}")
        end

        @client_manager.save!

        success

      end

    end

  end

end
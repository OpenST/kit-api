module ManagerManagement

  module Team

    class ListAdmins < ServicesBase

      # Initialize
      #
      # * Author: Shlok
      # * Date: 12/12/2018
      # * Reviewed By:
      #
      # @params [Integer] client_id (mandatory) - Client Id
      # @params [Integer] page_no (optional) - Page no.
      #
      # @return [ManagerManagement::Team::ListAdmins]
      #
      def initialize(params)

        super

        @client_id = @params[:client_id]
        @page_no =  @params[:page_no] || 1

        @page_size = 10

        @api_response_data = {}
        @api_response_data[:meta] = {}
        @api_response_data[:meta][:next_page_payload] = {}
        @api_response_data[:result_type] = 'client_managers'
        @mint_workflow = nil

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

          r = validate_and_sanitize
          return r unless r.success?

          r = fetch_workflows
          return r unless r.success?

          r = fetch_admins
          return r unless r.success?

          r = fetch_admin_email_ids
          return r unless r.success?

          success_with_data(@api_response_data)

        end

      end

      #private

      # Validate and sanitize
      #
      # * Author: Shlok
      # * Date: 12/12/2018
      # * Reviewed By:
      #
      # @return [Result::Base]
      #
      def validate_and_sanitize

        r = validate
        return r unless r.success?

        r = validate_page_no
        return r unless r.success?

        success

      end

      def validate_page_no

        return validation_error(
            'mm_su_i_1',
            'invalid_api_params',
            'invalid_page_no',
            GlobalConstant::ErrorAction.default
        ) unless Util::CommonValidator.is_numeric?(@page_no)

        @page_no = @page_no.to_i # Convert to integer if string is passed.

        success

      end

      # Fetch workflow
      #
      # * Author: Alpesh
      # * Date: 18/01/2018
      # * Reviewed By:
      #
      # @return [Result::Base]
      #
      def fetch_workflows
        workflows = CacheManagement::WorkflowByClient.new([@client_id]).fetch

        if workflows.present? && workflows[@client_id].present?
          workflows[@client_id].each do |wf|
            if wf.kind == GlobalConstant::Workflow.bt_stake_and_mint
              @mint_workflow ||= wf
              break
            end
          end
        end

        success
      end

      # Fetch client manager details
      #
      # * Author: Shlok
      # * Date: 12/12/2018
      # * Reviewed By:
      #
      # @return [Result::Base]
      #
      def fetch_admins

        offset_value = (@page_no - 1) * @page_size

        client_managers_data = ClientManager.where(
            'client_id = ? AND privileges & ? = 0',
            @client_id, ClientManager.privileges_config[GlobalConstant::ClientManager.has_been_deleted_privilege]).
            limit(@page_size + 1). # Fetch one more to check whether more entries are there or not.
        order('id DESC').
            offset(offset_value)

        # Fetch all client ids.
        @manager_ids = client_managers_data.select(:manager_id).all.collect(&:manager_id)

        # Fetch all client info.
        client_info = client_managers_data.to_a

        # Format the managers info
        client_managers_info = []
        client_info.each do |client_manager|
          client_manager = client_manager.formatted_cache_data
          client_managers_info.push(client_manager)
        end

        # If more entries are still available, populate next_page_payload in response.
        if @manager_ids.length > @page_size
          @api_response_data[:meta][:next_page_payload][:page_size] = @page_size
          @api_response_data[:meta][:next_page_payload][:page_no] = @page_no + 1
          client_managers_info = client_managers_info.first(@page_size)
        end

        @api_response_data[@api_response_data[:result_type]] = client_managers_info

        success

      end

      # Fetch manager details
      #
      # * Author: Shlok
      # * Date: 12/12/2018
      # * Reviewed By:
      #
      # @return [Result::Base]
      #
      def fetch_admin_email_ids

        managers_data = CacheManagement::Manager.new(@manager_ids).fetch

        @api_response_data[:managers] = managers_data

        success

      end

    end

  end

end
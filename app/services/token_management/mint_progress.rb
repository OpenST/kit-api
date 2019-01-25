module TokenManagement
  class MintProgress < TokenManagement:: Base

    # Initialize
    #
    # * Author: Anagha
    # * Date: 23/01/2019
    # * Reviewed By:
    #
    # @params [Integer] client_id (mandatory) - Client Id
    #
    #
    def initialize(params)
      super
      @client_manager = params[:client_manager]
      @api_response_data = {}
    end


    # Perform
    #
    # * Author: Anagha
    # * Date: 23/01/2019
    # * Reviewed By:
    #
    # @return [Result::Base]
    #
    def perform

      handle_errors_and_exceptions do

        validate_and_sanitize

        fetch_and_validate_token

        add_token_to_response

        @token_id = @token[:id]

        fetch_workflow

        fetch_workflow_current_status

        fetch_default_price_points

        append_logged_in_manager_details

        success_with_data(@api_response_data)

      end
    end

    # Validate and sanitize
    #
    # * Author: Anagha
    # * Date: 24/01/2018
    # * Reviewed By:
    #
    # @return [Result::Base]
    #
    def validate_and_sanitize
      validate

      unless Util::CommonValidator.is_integer?(@client_id)
        return validation_error(
          'a_s_tm_mp_1',
          'invalid_api_params',
          ['invalid_client_id'],
          GlobalConstant::ErrorAction.default
        )
      end
    end

    # Fetch workflow details
    #
    # * Author: Shlok
    # * Date: 21/01/2019
    # * Reviewed By:
    #
    # @return [Result::Base]
    #
    def fetch_workflow

      workflows = CacheManagement::WorkflowByClient.new([@client_id]).fetch
      @api_response_data[:workflow] = []

      if(workflows.present? && workflows[@client_id].present?)
        workflows[@client_id].each do |wf|
          if wf.status == GlobalConstant::Workflow.in_progress
            @api_response_data[:workflow] = {
              id: wf.id,
              kind: wf.kind
            }
          end
        end
      end
      @workflow_id = @api_response_data[:workflow][0][:id]

      success
    end

    # Fetch workflow current status
    #
    #
    # * Author: Ankit
    # * Date: 16/01/2019
    # * Reviewed By:
    #
    # @return [Result::Base]
    def fetch_workflow_current_status

      cached_response_data = CacheManagement::WorkflowStatus.new([@workflow_id]).fetch

      workflow_current_step = {}
      if cached_response_data[@workflow_id].present?
        workflow_current_step = cached_response_data[@workflow_id][:current_step]
      end
      @api_response_data['workflow_current_step'] = workflow_current_step
      #{@api_response_data['workflow'] = {
      #  id: @workflow_id,
      #  kind: GlobalConstant::Workflow.bt_stake_and_mint
      #}}"

      success
    end


    # Fetch default price points
    #
    #
    # * Author: Anagha
    # * Date: 23/01/2019
    # * Reviewed By:
    #
    # @return [Result::Base]
    def fetch_default_price_points
      @api_response_data[:price_points] = CacheManagement::OstPricePointsDefault.new.fetch

      success
    end

    # Append logged in manager details
    #
    # * Author: Anagha
    # * Date: 23/01/2018
    # * Reviewed By:
    #
    # @return [Result::Base]
    #
    def append_logged_in_manager_details
      return success unless @client_manager.present?

      if @client_manager.present?
        @api_response_data[:client_manager] = @client_manager
      end

      success
    end


  end
end


class GetWorkflowStatus < ServicesBase

  # Initialize
  #
  # * Author: Anagha
  # * Date: 15/01/2019
  # * Reviewed By:
  #
  # @params [Integer] parent_id (mandatory) - workflow parent Id
  #
  # @return [TokenSetup::SetupProgress]
  def initialize(params)

    super

    @workflow_id = params[:workflow_id]

    @api_response_data = {}

  end

  # Perform
  #
  # * Author: Anagha
  # * Date: 15/01/2019
  # * Reviewed By:
  #
  # @return [Result::Base]
  def perform
    handle_errors_and_exceptions do

      r = validate_and_sanitize
      return r unless r.success?

      r = fetch_data
      return r unless r.success?

      return success_with_data(@api_response_data)
    end
  end

  #private

  # Validate and sanitize
  #
  # * Author: Anagha
  # * Date: 15/01/2019
  # * Reviewed By:
  #
  # @return [Result::Base]
  #
  def validate_and_sanitize

    r = validate
    return r unless r.success?

    unless Util::CommonValidator.is_integer?(@workflow_id)
      return validation_error(
        'a_s_gws_1',
        'invalid_api_params',
        ['workflow_id'],
        GlobalConstant::ErrorAction.default
      )
    end

    @workflow_id = @workflow_id.to_i

    success
  end

  # fetch data from cache
  #
  # * Author: Ankit
  # * Date: 15/01/2019
  # * Reviewed By:
  #
  # @return [Result::Base]
  #
  def fetch_data

    cached_workflow_data = CacheManagement::Workflow.new([@workflow_id]).fetch

    if cached_workflow_data[@workflow_id].blank?
       fail OstCustomError.new validation_error(
                                'a_s_gws_2',
                                'invalid_api_params',
                                ['workflow_id'],
                                GlobalConstant::ErrorAction.default
                              )
    end

    @api_response_data['workflow'] = {
      id: @workflow_id,
      kind: cached_workflow_data[@workflow_id][:kind]
    }


    cached_workflow_status_data = CacheManagement::WorkflowStatus.new([@workflow_id]).fetch

    @api_response_data['workflow_current_step'] = {}
    if cached_workflow_status_data[@workflow_id][:current_step].present?
      @api_response_data['workflow_current_step'] = cached_workflow_status_data[@workflow_id][:current_step]
    end

    success_with_data(@api_response_data)
  end

end




class GetWorkflowStatus < ServicesBase

  # Initialize
  #
  # * Author: Anagha
  # * Date: 15/01/2019
  # * Reviewed By: Puneet
  #
  # @params [Integer] workflow_id (mandatory) - workflow parent Id
  #
  # @return [GetWorkflowStatus]
  #
  def initialize(params)

    super

    @workflow_id = params[:workflow_id]

    @api_response_data = {}

  end

  # Perform
  #
  # * Author: Anagha
  # * Date: 15/01/2019
  # * Reviewed By: Puneet
  #
  # @return [Result::Base]
  #
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
  # * Reviewed By: Puneet
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
  # * Reviewed By: Puneet
  #
  # @return [Result::Base]
  #
  def fetch_data

    cached_workflow_data = KitSaasSharedCacheManagement::Workflow.new([@workflow_id]).fetch

    if cached_workflow_data[@workflow_id].blank?
       return validation_error(
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

    begin
      @api_response_data['workflow_payload'] = Oj.load(cached_workflow_data[@workflow_id][:response_data], {})
    rescue => e
      @api_response_data['workflow_payload'] = {}
    end

    cached_workflow_status_data = KitSaasSharedCacheManagement::WorkflowStatus.new([@workflow_id]).fetch

    @api_response_data['workflow_current_step'] = {}
    if cached_workflow_status_data[@workflow_id][:current_step].present?
      @api_response_data['workflow_current_step'] = cached_workflow_status_data[@workflow_id][:current_step]
    end

    success
  end

end




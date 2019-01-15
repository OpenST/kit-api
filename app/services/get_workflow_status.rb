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
        'workflow_id',
        GlobalConstant::ErrorAction.default
      )
    end

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

    cached_response_data = CacheManagement::WorkflowStatus.new([@workflow_id]).fetch
    @api_response_data['workflow_current_step'] = cached_response_data[@workflow_id]

    workflow_entity = {}
    workflow_entity['id'] = @workflow_id
    workflow_entity['kind'] = GlobalConstant::WorkflowStatus.token_deploy_workflow_kind

    @api_response_data['workflow'] = workflow_entity
    success_with_data(@api_response_data)
  end


end




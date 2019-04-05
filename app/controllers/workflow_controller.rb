class WorkflowController < AuthenticationController

  # Get workflow status
  #
  # * Author: Ankit
  # * Date: 15/01/2019
  # * Reviewed By: Puneet
  #
  def workflow_status
    service_response = ::GetWorkflowStatus.new(params).perform
    return render_api_response(service_response)
  end

end
class DeveloperController < WebController

  # Get workflow status
  #
  # * Author: Ankit
  # * Date: 15/01/2019
  # * Reviewed By:
  #
  def developer_get
    service_response = DeveloperManagement::FetchDetails.new(params).perform
    render_api_response(service_response)
  end

end
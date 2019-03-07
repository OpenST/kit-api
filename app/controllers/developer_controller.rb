class DeveloperController < AuthenticationController

  # Get developer's page data
  #
  # * Author: Ankit
  # * Date: 04/02/2019
  # * Reviewed By: Sunil
  #
  def developer_get
    service_response = DeveloperManagement::FetchDetails.new(params).perform
    render_api_response(service_response)
  end

  # Get developer's api key and secret key
  #
  # * Author: Ankit
  # * Date: 04/02/2019
  # * Reviewed By: Sunil
  #
  def api_keys_get
    service_response = ClientManagement::ApiCredentials::Fetch.new(params).perform
    render_api_response(service_response)
  end

  # Generate new / Rotate api keys
  #
  # * Author: Ankit
  # * Date: 04/02/2019
  # * Reviewed By: Sunil
  #
  def api_keys_rotate
    service_response = ClientManagement::ApiCredentials::Rotate.new(params).perform
    render_api_response(service_response)
  end

  # Deactivate key
  #
  # * Author: Ankit
  # * Date: 04/02/2019
  # * Reviewed By: Sunil
  #
  def api_keys_deactivate
    service_response = ClientManagement::ApiCredentials::Deactivate.new(params).perform
    render_api_response(service_response)
  end

end
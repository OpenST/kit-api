class DeveloperController < AuthenticationController

  # Get developer's page data
  #
  # * Author: Ankit
  # * Date: 04/02/2019
  # * Reviewed By: Sunil
  #
  def developer_get
    service_response = DeveloperManagement::FetchDetails.new(params).perform
    return render_api_response(service_response)
  end

  # Get developer's api key and secret key
  #
  # * Author: Ankit
  # * Date: 04/02/2019
  # * Reviewed By: Sunil
  #
  def api_keys_get
    service_response = ClientManagement::ApiCredentials::Fetch.new(params).perform
    return render_api_response(service_response)
  end

  # Generate new / Rotate api keys
  #
  # * Author: Ankit
  # * Date: 04/02/2019
  # * Reviewed By: Sunil
  #
  def api_keys_rotate
    service_response = ClientManagement::ApiCredentials::Rotate.new(params).perform
    return render_api_response(service_response)
  end

  # Deactivate key
  #
  # * Author: Ankit
  # * Date: 04/02/2019
  # * Reviewed By: Sunil
  #
  def api_keys_deactivate
    service_response = ClientManagement::ApiCredentials::Deactivate.new(params).perform
    return render_api_response(service_response)
  end

  # Deactivate key
  #
  # * Author: Alpesh
  # * Date: 07/06/2019
  # * Reviewed By:
  #
  def webhook_secret_get
    service_response = ClientManagement::WebhookSecrets::Fetch.new(params).perform
    return render_api_response(service_response)
  end

  # Deactivate key
  #
  # * Author: Alpesh
  # * Date: 10/06/2019
  # * Reviewed By:
  #
  def webhook_secret_rotate
    service_response = ClientManagement::WebhookSecrets::Rotate.new(params).perform
    return render_api_response(service_response)
  end

  # Deactivate key
  #
  # * Author: Alpesh
  # * Date: 10/06/2019
  # * Reviewed By:
  #
  def delete_webhook_secret
    service_response = ClientManagement::WebhookSecrets::Delete.new(params).perform
    return render_api_response(service_response)
  end

end
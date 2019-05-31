class DeveloperController < AuthenticationController

  before_action :authenticate_developer_page_access
  
  # Get developer's page data
  #
  # * Author: Ankit
  # * Date: 04/02/2019
  # * Reviewed By: Sunil
  #
  def developer_get
    params[:show_keys_enable_flag] = @show_keys_enable_flag
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
    params[:show_keys_enable_flag] = @show_keys_enable_flag
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

  private
  
  # Authenticate developer page access
  # Check if secure data access can be shown or email round-trip is required
  #
  # * Author: Dhananjay
  # * Date: 29/05/2019
  # * Reviewed By:
  #
  def authenticate_developer_page_access
    params[:sda_cookie_value] = cookies[GlobalConstant::Cookie.secure_data_access_cookie_name.to_sym]
    params[:action_name] = action_name
    service_response = DeveloperManagement::VerifyCookie::SecureDataAccess.new(params).perform

    if service_response.success?
      # NOTE: delete cookie value from data
      cookie_value = service_response.data.delete(:cookie_value)
      set_cookie(
        GlobalConstant::Cookie.secure_data_access_cookie_name,
        cookie_value,
        GlobalConstant::Cookie.secure_data_access_cookie_expiry.from_now
      )

      @show_keys_enable_flag = service_response.data[:show_keys_enable_flag]
    end
  end
  
end
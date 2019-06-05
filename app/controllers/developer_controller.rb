class DeveloperController < AuthenticationController

  before_action :authenticate_developer_page_access
  
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

  private
  
  # Authenticate developer page access
  # Check if secure data access can be shown or email round-trip is required
  #
  # * Author: Dhananjay
  # * Date: 29/05/2019
  # * Reviewed By:
  #
  def authenticate_developer_page_access
    sda_cookie_verification_params = {
      sda_cookie_value: cookies[GlobalConstant::Cookie.secure_data_access_cookie_name.to_sym],
      action_name: action_name,
      manager_id: params[:manager_id]
    }
    cookie_verification_response = DeveloperManagement::VerifySecureDataAccess.new(sda_cookie_verification_params).perform

    puts "authenticate_developer_page_access::::service_response=====#{cookie_verification_response.to_json}"

    if cookie_verification_response.success?
      # NOTE: delete cookie value from data
      cookie_value = cookie_verification_response.data.delete(:cookie_value)
      set_cookie(
        GlobalConstant::Cookie.secure_data_access_cookie_name,
        cookie_value,
        GlobalConstant::Cookie.secure_data_access_cookie_expiry.from_now
      )

      params[:show_keys_enable_flag] = cookie_verification_response.data[:show_keys_enable_flag]
      params[:email_already_sent_flag] = cookie_verification_response.data[:email_already_sent_flag]
      puts "authenticate_developer_page_access:::PARAMS=========#{params.to_json}"
    else
      handle_sda_cookie_validation_failure(cookie_verification_response)
    end

  end

  # Handle secure data access cookie validation failure response
  #
  # 1. delete cookie
  # 3. remove authentication related critical data to sent in response
  #
  # * Author: Dhananjay
  # * Date: 05/06/2019
  # * Reviewed By:
  #
  def handle_sda_cookie_validation_failure(cookie_verify_rsp)

    # Clear cookie
    delete_cookie(GlobalConstant::Cookie.secure_data_access_cookie_name)

    # Set 401 header
    cookie_verify_rsp.go_to = GlobalConstant::GoTo.developer
    cookie_verify_rsp.http_code = GlobalConstant::ErrorCode.unauthorized_access

    cookie_verify_rsp.data = {}

    return render_api_response(cookie_verify_rsp)

  end
  
end
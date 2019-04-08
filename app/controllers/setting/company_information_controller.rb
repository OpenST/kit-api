class Setting::CompanyInformationController < AuthenticationController
  skip_before_action :authenticate_sub_env_access

  before_action :authenticate_by_password_cookie

  # Company Information Get request
  #
  # * Author: Anagha
  # * Date: 08/04/2019
  # * Reviewed By:
  #
  def company_information_get
    service_response = ClientManagement::GetClientInfo.new(params).perform
    render_api_response(service_response)
  end

  # Company Information Post request
  #
  # * Author: Anagha
  # * Date: 08/04/2019
  # * Reviewed By:
  #
  def company_information_post
    service_response = ClientManagement::InsertClientInfo.new(params).perform
    render_api_response(service_response)
  end

end
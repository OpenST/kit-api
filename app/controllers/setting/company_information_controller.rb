class Setting::CompanyInformationController < AuthenticationController
  skip_before_action :authenticate_sub_env_access

  before_action :authenticate_by_password_cookie

  # Get Request for Company Information Page
  #
  # * Author: Anagha
  # * Date: 08/04/2019
  # * Reviewed By: Kedar
  #
  def get
    params[:luse_cookie_value] = cookies[GlobalConstant::Cookie.last_used_env_cookie_name.to_sym]
    service_response = ClientManagement::GetClientInfo.new(params).perform

    return render_api_response(service_response)
  end

  # Update Company Information Post Request
  #
  # * Author: Anagha
  # * Date: 08/04/2019
  # * Reviewed By: Kedar
  #
  def update
    service_response = ClientManagement::UpdateClientInfo.new(params).perform

    return render_api_response(service_response)
  end

end
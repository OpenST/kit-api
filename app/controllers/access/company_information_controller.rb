class Access::CompanyInformationController < AuthenticationController
  skip_before_action :authenticate_by_mfa_cookie
  skip_before_action :authenticate_sub_env_access

  before_action :authenticate_by_password_cookie

  def company_information_get
    service_response = ClientManagement::GetClientInfo.new(params).perform
    render_api_response(service_response)
  end

  def company_information_post

  end

end
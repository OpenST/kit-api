class Setting::CompanyInformationController < AuthenticationController
  skip_before_action :authenticate_sub_env_access

  before_action :perform_common_validations

  # Get Request for Company Information Page
  #
  # * Author: Anagha
  # * Date: 08/04/2019
  # * Reviewed By: Kedar
  #
  def get
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

  private

  # Perform common validations
  #
  # * Author: Ankit
  # * Date: 10/04/2019
  # * Reviewed By:
  #
  def perform_common_validations
    luse_cookie_value = cookies[GlobalConstant::Cookie.last_used_env_cookie_name.to_sym]
    client = params[:client]

    return unless client[:properties].include?(GlobalConstant::Client.has_company_info_property)

    #check the cookie value here and redirect accordingly
    if luse_cookie_value == GlobalConstant::Cookie.mainnet_env
      #redirect to mainnet token dashboard
      goto_screen = GlobalConstant::GoTo.mainnet_token_dashboard
    else
      #redirect to token dashboard
      goto_screen = GlobalConstant::GoTo.sandbox_token_dashboard
    end

    service_response =  error_with_go_to(
      'a_s_cm_gci_1',
      'unauthorized_to_perform_action',
      goto_screen
    )

    render_api_response(service_response) and return
  end

end
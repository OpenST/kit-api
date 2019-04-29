class Token::SetupController < AuthenticationController

  skip_before_action :authenticate_sub_env_access, only: [
    :request_whitelist
  ]

  # Get token details before setup
  #
  # * Author: Ankit
  # * Date: 19/01/2019
  # * Reviewed By: Sunil
  #
  def token_details_get
    service_response = TokenManagement::GetTokenDetailsBeforeSetup.new(params).perform

    # set last used env cookie
    set_cookie(
      GlobalConstant::Cookie.last_used_env_cookie_name,
      GlobalConstant::Base.main_sub_environment? ? GlobalConstant::Cookie.mainnet_env : GlobalConstant::Cookie.sandbox_env,
      GlobalConstant::Cookie.last_used_env_cookie_expiry
    )

    return render_api_response(service_response)
  end

  # Set token details
  #
  # * Author: Ankit
  # * Date: 19/01/2019
  # * Reviewed By: Sunil
  #
  def token_details_post
    service_response = TokenManagement::InsertTokenDetails.new(params).perform
    return render_api_response(service_response)
  end

  # Start token deployment
  #
  # * Author: Ankit
  # * Date: 19/01/2019
  # * Reviewed By: Sunil
  #
  def deploy_post
    service_response = TokenManagement::StartDeployment.new(params).perform
    return render_api_response(service_response)
  end

  # Start token deployment
  #
  # * Author: Shlok
  # * Date: 21/01/2018
  # * Reviewed By: Sunil
  #
  def deploy_get
    service_response = TokenManagement::GetDeploymentDetail.new(params).perform
    return render_api_response(service_response)
  end

  # Whitelisting
  #
  # * Author: Ankit
  # * Date: 30/01/2019
  # * Reviewed By: Sunil
  #
  def request_whitelist
    service_response = TokenManagement::RequestWhitelist.new(params).perform
    return render_api_response(service_response)
  end

  # Get Balance
  #
  # * Author: Ankit
  # * Date: 29/04/2019
  # * Reviewed By:
  #
  def balance_get
    service_response = TokenManagement::GetBalance.new(params).perform
    return render_api_response(service_response)
  end
end

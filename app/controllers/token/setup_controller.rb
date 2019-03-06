class Token::SetupController < WebController

  before_action :verify_is_xhr , :except => [:token_details_get, :deploy_get]

  before_action :is_client_whitelisted, :only => [:token_details_get]

  # Get token details
  #
  # * Author: Ankit
  # * Date: 19/01/2019
  # * Reviewed By: Sunil
  #
  def token_details_get
    service_response = TokenManagement::GetTokenDetails.new(params).perform

    # set last used env cookie
    set_cookie(
      GlobalConstant::Cookie.last_used_env_cookie_name,
      GlobalConstant::Base.main_sub_environment? ? GlobalConstant::Cookie.mainnet_env : GlobalConstant::Cookie.sandbox_env,
      GlobalConstant::Cookie.last_used_env_cookie_expiry
    )

    render_api_response(service_response)
  end

  # Set token details
  #
  # * Author: Ankit
  # * Date: 19/01/2019
  # * Reviewed By: Sunil
  #
  def token_details_post
    service_response = TokenManagement::InsertTokenDetails.new(params).perform
    render_api_response(service_response)
  end

  # Start token deployment
  #
  # * Author: Ankit
  # * Date: 19/01/2019
  # * Reviewed By: Sunil
  #
  def deploy_post
    service_response = TokenManagement::StartDeployment.new(params).perform
    render_api_response(service_response)
  end

  # Start token deployment
  #
  # * Author: Shlok
  # * Date: 21/01/2018
  # * Reviewed By: Sunil
  #
  def deploy_get
    service_response = TokenManagement::GetDeploymentDetail.new(params).perform
    render_api_response(service_response)
  end

  # Start token minting
  #
  # * Author: Anagha
  # * Date: 23/01/2019
  # * Reviewed By: Sunil
  #
  def mint_progress
    service_response = TokenManagement::MintProgress.new(params).perform
    render_api_response(service_response)
  end

  # Whitelisting
  #
  # * Author: Ankit
  # * Date: 30/01/2019
  # * Reviewed By: Sunil
  #
  def request_whitelist
    service_response = TokenManagement::RequestWhitelist.new(params).perform
    render_api_response(service_response)
  end


  private

  # Check if client is white listed
  #
  # * Author: Ankit
  # * Date: 30/01/2019
  # * Reviewed By: Sunil
  #
  def is_client_whitelisted
    if GlobalConstant::Base.main_sub_environment?
      client_env_statuses = params[:client][:mainnet_statuses]
      env_whitelisted_status = GlobalConstant::Client.mainnet_whitelisted_status
      res_go_to = GlobalConstant::GoTo.sandbox_token_setup
    else
      client_env_statuses = params[:client][:sandbox_statuses]
      env_whitelisted_status = GlobalConstant::Client.sandbox_whitelisted_status
      res_go_to = GlobalConstant::GoTo.mainnet_token_setup
    end

    if !client_env_statuses.include?(env_whitelisted_status)
      service_response = error_with_go_to('a_c_t_sc_1', 'data_validation_failed', res_go_to)
      render_api_response(service_response)
    end
  end
end

class Manager::LoginController < Manager::BaseController

  before_action :append_user_agent_to_params
  
  before_action :verify_recaptcha, only: [:sign_up, :login, :send_reset_password_link]

  before_action :verify_mfa_cookie, except: [
      :sign_up_post,
      :sign_up_get,
      :mfa_post,
      :mfa_get,
      :login,
      :logout,
      :send_reset_password_link, :reset_password
  ]

  before_action :verify_password_cookie, only: [
      :mfa_post,
      :mfa_get,
  ]

  # Sign up page load get request (to fetch dynamic data in signup page. for ex. invite related data)
  #
  # * Author: Puneet
  # * Date: 08/12/2018
  # * Reviewed By: 
  #
  def sign_up_get

    if params[:i_t].present?
      service_response = ManagerManagement::SignUp::GetDetails.new(params).perform
    else
      service_response = Result::Base.success({})
    end

    render_api_response(service_response)

  end
  
  # Sign up Post request
  #
  # * Author: Puneet
  # * Date: 08/12/2018
  # * Reviewed By: 
  #
  def sign_up_post
    
    if params[:i_t].present?
      service_response = ManagerManagement::SignUp::ByInvite.new(params).perform
    else
      service_response = ManagerManagement::SignUp::WithoutInvite.new(params).perform
    end

    if service_response.success?
      # NOTE: delete cookie value from data
      cookie_value = service_response.data.delete(:cookie_value)
      set_cookie(
          GlobalConstant::Cookie.user_cookie_name,
          cookie_value,
          GlobalConstant::Cookie.password_auth_expiry.from_now
      )
    end

    render_api_response(service_response)
    
  end

  # Login Via Password
  #
  # * Author: Puneet
  # * Date: 08/12/2018
  # * Reviewed By:
  #
  def password_auth

    service_response = ManagerManagement::Login::PasswordAuth.new(params).perform

    if service_response.success?
      # NOTE: delete cookie value from data
      cookie_value = service_response.data.delete(:cookie_value)
      set_cookie(
          GlobalConstant::Cookie.user_cookie_name,
          cookie_value,
          GlobalConstant::Cookie.password_auth_expiry.from_now
      )
    end

    render_api_response(service_response)

  end

  # Get MFA Page details
  #
  # * Author: Puneet
  # * Date: 08/12/2018
  # * Reviewed By:
  #
  def mfa
    service_response = ManagerManagement::Login::MultiFactor::GetMfaUrl.new(params).perform
    render_api_response(service_response)
  end

  # Perform MFA
  #
  # * Author: Puneet
  # * Date: 08/12/2018
  # * Reviewed By:
  #
  def multi_factor_auth

    service_response = ManagerManagement::Login::MultiFactor::Authenticate.new(params).perform

    if service_response.success?
      # NOTE: delete cookie value from data
      cookie_value = service_response.data.delete(:double_auth_cookie_value)
      set_cookie(
          GlobalConstant::Cookie.user_cookie_name,
          cookie_value,
          GlobalConstant::Cookie.mfa_auth_expiry.from_now
      )
    end

    render_api_response(service_response)

  end

  # logout
  #
  # * Author: Puneet
  # * Date: 29/01/2018
  # * Reviewed By:
  #
  def logout
    service_response = ManagerManagement::Logout.new(params).perform
    # delete cookie irrespective if service response was success
    delete_cookie(GlobalConstant::Cookie.user_cookie_name)
    render_api_response(service_response)
  end

  # Send Reset Password link
  #
  # * Author: Pankaj
  # * Date: 15/01/2018
  # * Reviewed By:
  #
  def send_reset_password_link
    service_response = ManagerManagement::SendResetPasswordLink.new(params).perform
    render_api_response(service_response)
  end

  # Reset Password
  #
  # * Author: Pankaj
  # * Date: 15/01/2018
  # * Reviewed By:
  #
  def reset_password
    service_response = ManagerManagement::ResetPassword.new(params).perform
    render_api_response(service_response)
  end

  # Email verification of user
  #
  # * Author: Pankaj
  # * Date: 15/01/2018
  # * Reviewed By:
  #
  def verify_email
    service_response = ManagerManagement::DoubleOptIn.new(params).perform
    render_api_response(service_response)
  end

  # Send Email Verification Link
  #
  # * Author: Puneet
  # * Date: 15/02/2018
  # * Reviewed By:
  #
  def send_verify_email_link
    service_response = ManagerManagement::SendDoubleOptInLink.new(params).perform
    render_api_response(service_response)
  end
  
  def append_user_agent_to_params
    params[:browser_user_agent] = http_user_agent
  end

end

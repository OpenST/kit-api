class Access::LoginController < AuthenticationController

  skip_before_action :authenticate_by_mfa_cookie
  skip_before_action :authenticate_sub_env_access

  before_action :verify_recaptcha, only: [
    :password_auth,
    :send_reset_password_link
  ]

  # Sign up page load get request (to fetch dynamic data in signup page. for ex. invite related data)
  #
  # * Author: Puneet
  # * Date: 08/12/2018
  # * Reviewed By: Sunil
  #
  def sign_up_get

    ManagerManagement::Logout.new(params).perform
    # delete cookie irrespective if service response was success
    delete_cookie(GlobalConstant::Cookie.user_cookie_name)

    if params[:i_t].present?
      service_response = ManagerManagement::SignUp::GetDetails.new(params).perform
    else
      service_response = Result::Base.success({})
    end

    return render_api_response(service_response)

  end

  # Sign up Post request
  #
  # * Author: Shlok
  # * Date: 07/01/2019
  # * Reviewed By: Sunil
  #
  def sign_up_post

    if params[:i_t].present?
      service_response = ManagerManagement::SignUp::ByInvite.new(params).perform
    else
      # Verify recaptcha only if invite token is not passed.
      verify_recaptcha

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

    return render_api_response(service_response)

  end

  # Login Via Password
  #
  # * Author: Puneet
  # * Date: 08/12/2018
  # * Reviewed By: Sunil
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

    return render_api_response(service_response)

  end

  # Send Reset Password link
  #
  # * Author: Puneet
  # * Date: 15/01/2018
  # * Reviewed By: Sunil
  #
  def send_reset_password_link
    service_response = ManagerManagement::SendResetPasswordLink.new(params).perform
    return render_api_response(service_response)
  end

  # Reset Password
  #
  # * Author: Puneet
  # * Date: 15/01/2018
  # * Reviewed By: sunil
  #
  def reset_password
    service_response = ManagerManagement::ResetPassword.new(params).perform
    return render_api_response(service_response)
  end

  private

  # Verify Recaptcha
  #
  # * Author: Puneet
  # * Date: 11/12/2018
  # * Reviewed By: Sunil
  #
  def verify_recaptcha

    service_response = Google::Recaptcha.new({
                                               'response' => params['g-recaptcha-response'].to_s,
                                               'remoteip' => ip_address
                                             }).perform

    unless service_response.success?
      Rails.logger.error("---- Recaptcha::Verify Error: #{service_response.to_hash}")
      return render_api_response(service_response)
    end

    Rails.logger.debug('---- check_recaptcha_before_verification done')

  end

end

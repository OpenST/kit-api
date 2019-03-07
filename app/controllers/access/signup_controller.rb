class Access::SignupController < Access::BaseController

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

    render_api_response(service_response)

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

    render_api_response(service_response)
    
  end


end

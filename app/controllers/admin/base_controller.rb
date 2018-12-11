class Admin::BaseController < WebController
  
  include ActionController::HttpAuthentication::Basic::ControllerMethods
  
  skip_before_action :verify_mfa_cookie

  before_action :validate_admin

  private

  def validate_admin
    admins = {
      GlobalConstant::AdminBasicAuth.username => GlobalConstant::AdminBasicAuth.password
    }
    
    admin_secrets = [
      'FbDp6RgqMvNTKHk8z8BxYQErf2FjMW8EnvYYJ9QS', # Sunil
    ]
  
    authenticate_or_request_with_http_basic do |username, password|
      if admins[username].present? && admins[username] == password && admin_secrets.include?(params[:secret])
        true
      else
        false
      end
    end
    
    Rails.logger.info("Admin request from: #{params[:secret]}(secret)")
  end

end
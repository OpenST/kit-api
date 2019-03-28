class Admin::BaseController < AuthenticationController
  
  include ActionController::HttpAuthentication::Basic::ControllerMethods

  skip_before_action :authenticate_by_mfa_cookie
  skip_before_action :authenticate_sub_env_access

  before_action :validate_admin

  private

  def validate_admin

    basic_auth_credentials = {
      GlobalConstant::AdminBasicAuth.username => GlobalConstant::AdminBasicAuth.password
    }
    
    admin_secrets = [
      'YFbDp6RgqMvNTKHk8z8BxYJ9QSYQErf2FjMW8Env', # Jason
      'nVXe6BABW8Bb3n8h43XP8W5nTWm3HgJK2sMPaScH', # Shlomi
      'Cx74W6GV5fT9drz47kjDvYMqjGaAJxXrjatbwJ3y', # Ignas
      'UzHArPR5C4CbCXZVHMFDbjPuwG2BL4gbrfsThsQE', # Jean
      'DjJRQWA8bNdd84xceSNCqjydpf78suLZDYpvPcV7',  # Mohit
      'rpkYwd3GM2N7dXEkxtRLBwHvhZnVc88R5K8fbKD5', # Kevin
      'dF56K5DBC7ZL4CK6gdcQM7gUJPNauAyQwhDfAuAW', # Paul
    ]
  
    authenticate_or_request_with_http_basic do |username, password|

      if basic_auth_credentials[username].present? && basic_auth_credentials[username] == password && admin_secrets.include?(params[:secret])
        true
      else
        false
      end
    end
    
    Rails.logger.info("Admin request from: #{params[:secret][0..10]} (secret)")

  end

end
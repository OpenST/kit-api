class Admin::BaseController < AuthenticationController

  include ActionController::HttpAuthentication::Basic::ControllerMethods

  skip_before_action :authenticate_by_mfa_cookie
  skip_before_action :authenticate_sub_env_access

  http_basic_authenticate_with name: GlobalConstant::AdminBasicAuth.username, password: GlobalConstant::AdminBasicAuth.password

  before_action :validate_admin

  private

  def validate_admin

    admin_secrets = [
        'YFbDp6RgqMvNTKHk8z8BxYJ9QSYQErf2FjMW8Env', # Jason
        'nVXe6BABW8Bb3n8h43XP8W5nTWm3HgJK2sMPaScH', # Shlomi
        'Cx74W6GV5fT9drz47kjDvYMqjGaAJxXrjatbwJ3y', # Ignas
        'UzHArPR5C4CbCXZVHMFDbjPuwG2BL4gbrfsThsQE', # Jean
        'DjJRQWA8bNdd84xceSNCqjydpf78suLZDYpvPcV7',  # Mohit
        'rpkYwd3GM2N7dXEkxtRLBwHvhZnVc88R5K8fbKD5', # Kevin
        'dF56K5DBC7ZL4CK6gdcQM7gUJPNauAyQwhDfAuAW' # Paul
    ]

    unless admin_secrets.include?(params[:secret])
      r = Result::Base.error(
          internal_id: 'c_a_bc_1',
          general_error_identifier: 'something_went_wrong'
      )
      return render_api_response(r)
    end
  end

end
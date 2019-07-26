class SubenvNotificationController < ApplicationController

  before_action :authenticate_jwt

  def notify_post_signup
    if GlobalConstant::Base.sandbox_sub_environment?
      decoded_data = params[:decoded_token_data]
      BackgroundJob.enqueue(
          PostSignupSandboxTasksJob,
          {
              manager_id: decoded_data[:manager_id],
              client_id: decoded_data[:client_id]
          }
      )
    end

    render_api_response(success)
  end

  def authenticate_jwt
    r = SubenvCommunicationApi.new.decrypyt_request(params)
    unless r.success?
      r.go_to = GlobalConstant::GoTo.login
      r.http_code = GlobalConstant::ErrorCode.unauthorized_access

      r.data = {}

      render_api_response(r)
    end
  end

end
module CsrfTokenConcern

  extend ActiveSupport::Concern

  include Util::ResultHelper

  def handle_unverified_request

    ApplicationMailer.notify(
        body: 'Invalid Authenticity Token Exception',
        data: {
            controller: params[:controller],
            action: params[:action],
            authenticity_token: params[:authenticity_token],
            http_user_agent: http_user_agent,
            request_time: Time.now,
            page_loaded_at: params[:page_loaded_at]
        },
        subject: 'InvalidAuthenticityToken'
    ).deliver

    r = error_with_data(
      'ctc_1',
      'invalid_authenticity_token',
      GlobalConstant::ErrorAction.default
    )

    return render_api_response(r)

  end

end
class Manager::BaseController < WebController

  private

  # Verify Recaptcha
  #
  # * Author: Puneet
  # * Date: 11/12/2018
  # * Reviewed By:
  #
  def verify_recaptcha

    service_response = Google::Recaptcha.new({
                                                 'response' => params['g-recaptcha-response'].to_s,
                                                 'remoteip' => request.remote_ip.to_s
                                             }).perform

    unless service_response.success?
      Rails.logger.error("---- Recaptcha::Verify Error: #{service_response.to_hash}")
      render_api_response(service_response)
    end

    Rails.logger.info('---- check_recaptcha_before_verification done')

  end

end
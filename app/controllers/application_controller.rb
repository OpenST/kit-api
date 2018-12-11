class ApplicationController < ActionController::API

  # this is the top-most wrapper - to catch all the exceptions at any level
  prepend_around_action :handle_exceptions_gracefully

  # Sanitize URL params
  include Sanitizer
  include CookieConcern
  include Util::ResultHelper

  before_action :sanitize_params
  before_action :check_service_statuses

  after_action :set_response_headers

  def not_found

    r = Result::Base.error(
        {
            internal_id: 'ac_1',
            general_error_identifier: 'resource_not_found',
            http_code: GlobalConstant::ErrorCode.not_found
        }
    )

    render_api_response(r)

  end

  private

  #
  # Check if all services are up and running.
  # If not render Error Responses for all API's
  #
  # * Author: Puneet
  # * Date: 01/02/2018
  # * Reviewed By:
  #
  def check_service_statuses

    r = CacheManagement::SystemServiceStatuses.new().fetch

    if r.success? && r.data.present? && (r.data[:saas_api_available] != 1 || r.data[:company_api_available] != 1)
      r = Result::Base.error(
        internal_id: 'ac_2',
        general_error_identifier: 'api_under_maintenance',
        http_code: GlobalConstant::ErrorCode.under_maintenance,
        go_to: GlobalConstant::GoTo.service_unavailable
      )
      render_api_response(r)
    end

  end

  def sanitize_params
    sanitize_params_recursively(params)
  end

  def http_user_agent
    # User agent is required for cookie validation
    request.env['HTTP_USER_AGENT'].to_s
  end

  def ip_address
    request.remote_ip.to_s
  end

  def set_response_headers
    response.headers["X-Robots-Tag"] = 'noindex, nofollow'
    response.headers["Content-Type"] = 'application/json; charset=utf-8'
  end

  # Render API response
  #
  # * Author: Puneet
  # * Date: 24/01/2018
  # * Reviewed By: Puneet
  #
  def render_api_response(service_response)

    # calling to_json of Result::Base
    response_hash = service_response.to_json
    http_status_code = service_response.http_code

    # filter out not allowed http codes
    http_status_code = GlobalConstant::ErrorCode.ok unless GlobalConstant::ErrorCode.allowed_http_codes.include?(http_status_code)

    # sanitizing out error and data. only display_text and display_heading are allowed to be sent to FE.
    if !service_response.success?

      Rails.logger.error "#{response_hash}"

      err = response_hash.delete(:err) || {}
      if err.has_key?(:error_data)
        err[:error_data].delete(:trace) if err[:error_data].is_a?(Hash)
      end

      display_text = err[:display_text].blank? ? err[:msg].to_s : err[:display_text].to_s
      display_heading = err[:display_heading].blank? ? err[:msg].to_s : err[:display_heading].to_s

      response_hash[:err] = {
          display_text: display_text,
          display_heading: display_heading,
          error_data: (err[:error_data] || {})
      }

      response_hash[:data] = {}

    end

    if !service_response.success? && service_response.respond_to?(:go_to) && service_response.go_to.present?
      response_hash[:err][:go_to] = service_response.go_to
    end

    (render plain: Oj.dump(response_hash, mode: :compat), status: http_status_code)

  end

  # Handle exceptions gracefully
  #
  # * Author: Puneet
  # * Date: 24/01/2018
  # * Reviewed By: Puneet
  #
  def handle_exceptions_gracefully

    begin

      yield

    rescue => se
      Rails.logger.error("Exception in API: #{se.message}")
      ApplicationMailer.notify(
          body: {exception: {message: se.message, backtrace: se.backtrace}},
          data: {
              'params' => params
          },
          subject: 'Exception in API'
      ).deliver

      r = Result::Base.error(
          internal_id: 'ac_3',
          general_error_identifier: 'something_went_wrong'
      )

      render_api_response(r)

    end

  end

end

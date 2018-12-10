module Google

  class Recaptcha

    require 'http'

    include Util::ResultHelper

    def initialize(params)
      Rails.logger.info("--- Recaptcha::Recaptcha params: #{params}")
      @params = params.merge!(:secret => GlobalConstant::Recaptcha.secret_key)
    end

    def perform
      r = send_request_of_type
      Rails.logger.info("--- Recaptcha::Recaptcha response: #{r.inspect}")
      return r
    end

    private

    def send_request_of_type
      begin
        request_path = 'https://www.google.com/recaptcha/api/siteverify'
        response = HTTP.put(request_path, :form => @params)
        case response.status
          when 200
            parsed_response = Oj.load(response.body.to_s)
            if parsed_response['success']
              return success_with_data(response: parsed_response)
            else
              return error_with_data('rv_1',
                                     'something_went_wrong',
                                     GlobalConstant::ErrorAction.default,
                                     parsed_response)
            end
          else
            return error_with_data(
                'rv_2',
                'something_went_wrong',
                GlobalConstant::ErrorAction.default,
                {status: response.status}
            )
        end
      rescue => e
        return error_with_data(
            'rv_3',
            'something_went_wrong',
            GlobalConstant::ErrorAction.default
        )
      end
    end

  end

end
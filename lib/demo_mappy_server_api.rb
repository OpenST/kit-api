class DemoMappyServerApi

  include Util::ResultHelper

  require 'http'

  # Initialize
  #
  # * Author: Puneet
  # * Date: 10/04/2019
  # * Reviewed By: Sunil
  #
  # @return [DemoMappyServerApi]
  #
  def initialize
    @timeouts = {
        write: 5,
        connect: 5,
        read: 5
    }
  end

  # Send Api request
  #
  # * Author: Puneet
  # * Date: 10/04/2019
  # * Reviewed By: Sunil
  #
  # @return [Result::Base]
  #
  def send_request_of_type(request_type, path, params)

    begin

      request_path = "#{GlobalConstant::DemoMappyServer.api_endpoint}/#{path}"

      if GlobalConstant::Environment.is_development_env?
        # It overrides verification of SSL certificates
        ssl_context = OpenSSL::SSL::SSLContext.new
        ssl_context.verify_mode = OpenSSL::SSL::VERIFY_NONE
      end

      case request_type
        when 'get'
          response = HTTP.timeout(@timeouts)
                         .get(request_path, params: params)
        when 'post'
          response = HTTP.timeout(@timeouts)
                         .post(request_path, json: params)
        else
          return error_with_data(
              'l_dmsa_1',
              'something_went_wrong',
              GlobalConstant::ErrorAction.default
          )
      end

      parsed_response = Oj.load(response.body.to_s,{})

      if parsed_response.has_key?('success')
        # internal response
        if parsed_response['success']
          return success_with_data(HashWithIndifferentAccess.new(parsed_response['data']))
        else
          return error_with_formatted_error_data(
              "#{parsed_response['internal_id']} : #{parsed_response['code']} : st(l_dmsa_2)",
              parsed_response['msg'],
              parsed_response
          )
        end
      else
        return error_with_data(
            'l_dmsa_3',
            'something_went_wrong',
            GlobalConstant::ErrorAction.default
        )
      end
    rescue => e
      return error_with_data(
          'l_dmsa_4',
          'something_went_wrong',
          GlobalConstant::ErrorAction.default,
          {message: e.message}
      )
    end
  end

end
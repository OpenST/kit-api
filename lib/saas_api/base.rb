module SaasApi

  class Base

    include Util::ResultHelper

    require 'http'
    require 'openssl'

    # Initialize
    #
    # * Author: Kedar
    # * Date: 25/01/2018
    # * Reviewed By:
    #
    # @return [SaasApi::Base]
    #
    def initialize
      @timeouts = {
        write: 5,
        connect: 5,
        read: 5
      }
    end

    private

    # Send Api request
    #
    # * Author: Kedar
    # * Date: 25/01/2018
    # * Reviewed By:
    #
    # @return [Result::Base]
    #
    def send_request_of_type(request_type, path, params)
      begin

        request_path = "#{GlobalConstant::SaasApi.base_url}/#{path}"

        Rails.logger.info("-------------request_path----#{request_path}")

        if GlobalConstant::Environment.is_development_env?
          # It overrides verification of SSL certificates
          ssl_context = OpenSSL::SSL::SSLContext.new
          ssl_context.verify_mode = OpenSSL::SSL::VERIFY_NONE
        end

        parameterized_token = {token: get_jwt_token(params)}

        case request_type
          when 'get'
            response = HTTP.timeout(@timeouts)
                         .get(request_path, params: parameterized_token, ssl_context: ssl_context)
          when 'post'
            response = HTTP.timeout(@timeouts)
                         .post(request_path, json: parameterized_token, ssl_context: ssl_context)
          else
            return error_with_data(
                'l_ma_b_1',
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
               "#{parsed_response['err']['internal_id']} : #{parsed_response['err']['code']} : st(l_ma_b_2)",
                parsed_response['err']['msg'],
               parsed_response['err']['error_data']
            )
          end
        else
          return error_with_data(
              'l_ma_b_3',
              'something_went_wrong',
              GlobalConstant::ErrorAction.default
          )
        end
      rescue => e
        return error_with_data(
            'l_ma_b_4',
            'something_went_wrong',
            GlobalConstant::ErrorAction.default,
            {message: e.message}
        )
      end
    end

    # Create encrypted Token
    #
    # * Author: Kedar
    # * Date: 25/01/2018
    # * Reviewed By:
    #
    # @params [Hash] data
    #
    # @return [String] Encoded token
    #
    def get_jwt_token(data)
      payload = {data: data}
      secret_key = GlobalConstant::SaasApi.secret_key

      JWT.encode(payload, secret_key, 'HS256')
    end

  end

end
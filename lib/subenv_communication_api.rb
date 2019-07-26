class SubenvCommunicationApi

  include Util::ResultHelper

  require 'http'

  # Initialize
  #
  # * Author: Pankaj
  # * Date: 26/07/2019
  # * Reviewed By:
  #
  # @return [SubenvCommunicationApi]
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
  # * Author: Pankaj
  # * Date: 26/07/2019
  # * Reviewed By:
  #
  # @return [Result::Base]
  #
  def send_request_to(subenv, request_type, path, params)

    begin

      hs = "https://"
      if GlobalConstant::Environment.is_development_env?
        # It overrides verification of SSL certificates
        hs = "http://"
        ssl_context = OpenSSL::SSL::SSLContext.new
        ssl_context.verify_mode = OpenSSL::SSL::VERIFY_NONE
      end

      request_path = "#{hs}#{GlobalConstant::Base.cookie_domain}"
      if subenv == GlobalConstant::Environment.main_sub_environment
        request_path += "/#{GlobalConstant::Environment.mainnet_url_prefix}/"
      else
        request_path += "/#{GlobalConstant::Environment.testnet_url_prefix}/"
      end
      request_path += "api/#{path}"

      parameterized_token = {token: get_jwt_token(params)}

      case request_type
        when 'get'
          response = HTTP.timeout(@timeouts)
                         .get(request_path, params: parameterized_token)
        when 'post'
          response = HTTP.timeout(@timeouts)
                         .post(request_path, json: parameterized_token)
        else
          return error_with_data(
              'l_sca_1',
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
              "#{parsed_response['internal_id']} : #{parsed_response['code']} : st(l_sca_2)",
              parsed_response['msg'],
              parsed_response
          )
        end
      else
        return error_with_data(
            'l_sca_3',
            'something_went_wrong',
            GlobalConstant::ErrorAction.default
        )
      end
    rescue => e
      return error_with_data(
          'l_sca_4',
          'something_went_wrong',
          GlobalConstant::ErrorAction.default,
          {message: e.message}
      )
    end
  end

  # Decrypt request
  #
  # * Author: Pankaj
  # * Date: 26/07/2019
  # * Reviewed By:
  #
  # @return [Result::Base]
  #
  def decrypyt_request(params)
    begin
      decoded_token_data = JWT.decode(
          params[:token],
          GlobalConstant::Environment.subenv_communication_secret,
          true,
          {:algorithm => 'HS256'}
      )[0]["data"]

      params[:decoded_token_data] = HashWithIndifferentAccess.new(decoded_token_data)
      return success_with_data(params[:decoded_token_data])
    rescue => e
      return error_with_data(
          'l_sca_5',
          'something_went_wrong',
          GlobalConstant::ErrorAction.default,
          {message: e.message}
      )
    end
  end

  # Create encrypted Token for whitelisting parameter
  #
  def get_jwt_token(data)
    payload = {data: data}
    secret_key = GlobalConstant::Environment.subenv_communication_secret

    JWT.encode(payload, secret_key, 'HS256')
  end



end
module Ticketing
  
  module PipeDrive
    
    class Base
  
      include Util::ResultHelper
  
      require 'http'
      require "openssl"
  
      # Initialize
      #
      # * Author: Dhananjay
      # * Date: 16/04/2019
      # * Reviewed By:
      #
      # Sets @ost_pipedrive_user_id, @api_version, @deals_endpoint
      #
      # @return [Ticketing::PipeDrive::Base]
      #
      def initialize
        @api_version = GlobalConstant::PipeDrive.pipedrive_api_version
    
        @timeouts = {write: 10, connect: 5, read: 10}
      end
  
      private
  
      # Create request path
      #
      # * Author: Dhananjay
      # * Date: 16/04/2019
      # * Reviewed By:
      #
      # @return [String]
      #
      def create_request_path(endpoint, url_params={})
        query_param = url_params.to_query.gsub(/^&/, '')
        api_url = "#{GlobalConstant::PipeDrive.pipedrive_api_base_url}#{endpoint}"
        
        "#{api_url}?#{query_param}&api_token=#{GlobalConstant::PipeDrive.api_token}"
      end
  
      # Sends http request
      #
      # * Author: Dhananjay
      # * Date: 16/04/2019
      # * Reviewed By:
      #
      # @return [Result::Base]
      #
      def send_request_of_type(request_type, request_path, params={})
        begin
          response = {}
          # It overrides verification of SSL certificates
          ssl_context = OpenSSL::SSL::SSLContext.new
          ssl_context.verify_mode = OpenSSL::SSL::VERIFY_NONE
      
          case request_type
            when 'get'
              response = HTTP.timeout(@timeouts).get(request_path, params: params, ssl_context: ssl_context)
            when 'post'
              response = HTTP.timeout(@timeouts).post(request_path, json: params, ssl_context: ssl_context)
            else
              return error_with_data('l_t_pd_b_1',
                                     "Request type not implemented: #{request_type}",
                                     'Something Went Wrong.',
                                     GlobalConstant::ErrorAction.default)
          end
      
          parsed_response = Oj.load(response.to_s)
      
          case response.status
            when 200, 201
              if parsed_response['success']
                return success_with_data(parsed_response['data'])
              else
                return error_with_data('l_t_pd_b_2',
                                       'Something Went Wrong.',
                                       GlobalConstant::ErrorAction.default,
                                       {error: parsed_response['error']}
                )
              end
            else
              return error_with_data('l_t_pd_b_3',
                                     'Something Went Wrong.',
                                     GlobalConstant::ErrorAction.default ,
                                     {error: parsed_response['error']}
              )
          end
        rescue => e
          return error_with_data('l_t_pd_b_4',
                                 'Something Went Wrong.',
                                 GlobalConstant::ErrorAction.default,
                                 {error: "Exception in API call: #{e.message}"}
          )
        end
  
      end
      
    end
  
  end

end
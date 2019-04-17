module FormIntegration
  
  class PipeDrive
  
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
    def initialize
      @api_version = GlobalConstant::PipeDrive.pipedrive_api_version
      @ost_pipedrive_user_id = GlobalConstant::PipeDrive.ost_pipedrive_user_id
      
      @deals_endpoint = "/#{@api_version}/deals/"
      @organizations_endpoint = "/#{@api_version}/organizations"
      @persons_endpoint = "/#{@api_version}/persons"
      @deal_fields_endpoint = "/#{@api_version}/dealFields"
      
      @timeouts = {write: 10, connect: 5, read: 10}
    end

    # Get all deals
    #
    # * Author: Dhananjay
    # * Date: 16/04/2019
    # * Reviewed By:
    #
    # @return [Result::Base] returns an object of Result::Base class
    #
    def get_all_deals
      url_params = {
        "user_id" => @ost_pipedrive_user_id,
        "start" => 0,    #Pagination start
        "status" => 'all_not_deleted', # default status - 'all_not_deleted'
      }
      url_path = create_request_path(@deals_endpoint, url_params)
      
      r = send_request_of_type('get', url_path)
      return r unless r.success?
      success_with_data(r.data)
    end

    # Get all organizations
    #
    # * Author: Dhananjay
    # * Date: 16/04/2019
    # * Reviewed By:
    #
    # @return [Result::Base] returns an object of Result::Base class
    #
    def get_all_organizations
      url_params = {
        "start" => 0    #Pagination start
      }
      url_path = create_request_path(@organizations_endpoint, url_params)
  
      r = send_request_of_type('get', url_path)
      return r unless r.success?
      success_with_data(r.data)
    end

    # Get details for person id
    #
    # * Author: Dhananjay
    # * Date: 16/04/2019
    # * Reviewed By:
    #
    # @params [Integer] person_id (mandatory) - person id
    #
    # @return [Result::Base] returns an object of Result::Base class
    #
    def get_details_of_person(person_id)
      custom_persons_api_endpoint = "#{@persons_endpoint}/#{person_id}"
      url_path = create_request_path(custom_persons_api_endpoint)
      r = send_request_of_type('get', url_path)
      return r unless r.success?
      success_with_data(r.data)
    end

    # Create a deal
    #
    # * Author: Dhananjay
    # * Date: 16/04/2019
    # * Reviewed By:
    #
    # @params [String] deal_title (mandatory) - deal title
    # @params [Integer] person_id (mandatory) - person id
    # @params [Integer] org_id (mandatory) - organization id
    # @params [String] is_enterprise (optional) - has 1M users or not
    # @params [String] has_mobile_app (optional) - has mobile app or not
    #
    # @return [Result::Base] returns an object of Result::Base class
    #
    def create_deal(deal_title, person_id, org_id, is_enterprise, has_mobile_app)
      enterprise_custom_field_key = GlobalConstant::PipeDrive.pipedrive_deal_enterprise_custom_field_key
      mobile_app_custom_field_key = GlobalConstant::PipeDrive.pipedrive_deal_mobile_app_custom_field_key
      
      url_path = create_request_path(@deals_endpoint)
      custom_params = {
        title: deal_title,
        person_id: person_id,
        org_id: org_id
      }
      custom_params[enterprise_custom_field_key.to_sym] = is_enterprise
      custom_params[mobile_app_custom_field_key.to_sym] = has_mobile_app
      
      r = send_request_of_type('post', url_path, custom_params)
      return r unless r.success?
      success_with_data(r.data)
    end

    # Create an organization
    #
    # * Author: Dhananjay
    # * Date: 16/04/2019
    # * Reviewed By:
    #
    # @params [String] org_name (mandatory) - organization name
    #
    # @return [Result::Base] returns an object of Result::Base class
    #
    def create_organization(org_name)
      url_path = create_request_path(@organizations_endpoint)
      custom_params = {
        name: org_name
      }
  
      r = send_request_of_type('post', url_path, custom_params)
      return r unless r.success?
      success_with_data(r.data)
    end

    # Add a person
    #
    # * Author: Dhananjay
    # * Date: 16/04/2019
    # * Reviewed By:
    #
    # @params [String] first_name (mandatory) - first name
    # @params [String] last_name (mandatory) - last name
    # @params [String] email (mandatory) - email
    # @params [Integer] org_id (mandatory) - org id
    #
    # @return [Result::Base] returns an object of Result::Base class
    #
    def add_person(first_name, last_name, email, org_id)
      url_path = create_request_path(@persons_endpoint)
      custom_params = {
        name: "#{first_name} #{last_name}",
        org_id: org_id,
        email: email
      }
      r = send_request_of_type('post', url_path, custom_params)
      return r unless r.success?
      success_with_data(r.data)
    end

    # Add a custom field in deals
    #
    # * Author: Dhananjay
    # * Date: 16/04/2019
    # * Reviewed By:
    #
    # @params [String] field_name (mandatory) - field name for custom attribute field
    # @params [String] options_array (mandatory) - allowed values for custom field
    #
    # @return [Result::Base] returns an object of Result::Base class
    #
    def add_custom_field_in_deals(field_name, options_array)
      url_path = create_request_path(@deal_fields_endpoint)
      custom_params = {
        name: field_name,
        field_type: "enum",
        options: options_array
      }
      r = send_request_of_type('post', url_path, custom_params)
      return r unless r.success?
      success_with_data(r.data)
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
      req_path = "#{api_url}?#{query_param}&api_token=#{GlobalConstant::PipeDrive.api_token}"
    end

    # Sends http request
    #
    # * Author: Dhananjay
    # * Date: 16/04/2019
    # * Reviewed By:
    #
    # @return [Result::Base] returns an object of Result::Base class
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
            return error_with_data('fi_pd_1',
                                   "Request type not implemented: #{request_type}",
                                   'Something Went Wrong.',
                                   GlobalConstant::ErrorAction.default)
        end
        
        parsed_response = Oj.load(response.to_s)
        
        case response.status
          when 200, 201
            if parsed_response['success']
              return success_with_data(parsed_response)
            else
              return error_with_data('fi_pd_2',
                                     'Something Went Wrong.',
                                     GlobalConstant::ErrorAction.default,
                                     {error: parsed_response['error']}
                                     )
            end
          else
            return error_with_data('fi_pd_3',
                                   'Something Went Wrong.',
                                   GlobalConstant::ErrorAction.default ,
                                   {error: parsed_response['error']}
            )
        end
      rescue => e
        return error_with_data('fi_pd_4',
                               'Something Went Wrong.',
                               GlobalConstant::ErrorAction.default,
                               {error: "Exception in API call: #{e.message}"}
        )
      end
      
    end
  
  end
  
end
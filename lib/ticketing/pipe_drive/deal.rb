module Ticketing
  
  module PipeDrive
    
    class Deal < Ticketing::PipeDrive::Base
  
      # Initialize
      #
      # * Author: Dhananjay
      # * Date: 16/04/2019
      # * Reviewed By:
      #
      # @return [Ticketing::PipeDrive::Deal]
      #
      def initialize
        super

        # TODO - Dhananjay - add api params validations
        @deals_endpoint = "/#{@api_version}/deals/"
        @deal_fields_endpoint = "/#{@api_version}/dealFields"
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
      # @return [Result::Base]
      #
      def create(deal_title, person_id, org_id, is_enterprise, has_mobile_app)
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

      # Add a custom field in deals
      #
      # * Author: Dhananjay
      # * Date: 16/04/2019
      # * Reviewed By:
      #
      # @params [String] field_name (mandatory) - field name for custom attribute field
      # @params [String] options_array (mandatory) - allowed values for custom field
      #
      # @return [Result::Base]
      #
      def add_custom_field(field_name, options_array)
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
      
    end

  end

end
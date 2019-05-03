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
      # @params [String] one_m_users_flag_str (mandatory) - has 1M users or not
      # @params [String] mobile_app_flag_str (mobile_app_flag_str) - has mobile app or not
      #
      # @return [Result::Base]
      #
      def create(deal_title, person_id, org_id, one_m_users_flag_str, mobile_app_flag_str)
  
        validation_errors = []
  
        validation_errors.push('invalid_deal_title') unless Util::CommonValidator.is_string?(deal_title)
        validation_errors.push('invalid_person_id') unless Util::CommonValidator.is_integer?(person_id)
        validation_errors.push('invalid_org_id') unless Util::CommonValidator.is_integer?(org_id)
        validation_errors.push('invalid_one_m_users_flag_str') unless Util::CommonValidator.is_string?(one_m_users_flag_str)
        validation_errors.push('invalid_mobile_app_flag_str') unless Util::CommonValidator.is_string?(mobile_app_flag_str)
        
        return validation_error(
          'l_t_pd_d_1',
          'something_went_wrong',
          validation_errors,
          GlobalConstant::ErrorAction.default
        ) if validation_errors.present?
        
        enterprise_custom_field_key = GlobalConstant::PipeDrive.pipedrive_deal_enterprise_custom_field_key
        mobile_app_custom_field_key = GlobalConstant::PipeDrive.pipedrive_deal_mobile_app_custom_field_key

        url_path = create_request_path(@deals_endpoint)

        is_enterprise = one_m_users_flag_str  == 'Enterprise'
        
        stage_id = is_enterprise ?
                     GlobalConstant::PipeDrive.ost_platform_enterprise_stage_id :
                     GlobalConstant::PipeDrive.ost_platform_business_stage_id

        user_id = is_enterprise ?
                    GlobalConstant::PipeDrive.ost_pipedrive_enterprise_user_id :
                    GlobalConstant::PipeDrive.ost_pipedrive_business_user_id
        
        custom_params = {
          title: deal_title,
          user_id: user_id,
          person_id: person_id,
          org_id: org_id,
          stage_id: stage_id   # ID of the stage where this deal will be placed in a pipeline
        }
        custom_params[enterprise_custom_field_key.to_sym] = one_m_users_flag_str
        custom_params[mobile_app_custom_field_key.to_sym] = mobile_app_flag_str
  
        r = send_request_of_type('post', url_path, custom_params)
        return r unless r.success?

        success_with_data(
          {
            deal_id: r[:data]['id']
          })
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
  
        validation_errors = []
  
        validation_errors.push('invalid_field_name') unless Util::CommonValidator.is_string?(field_name)
        validation_errors.push('invalid_options_array') unless Util::CommonValidator.is_array?(options_array)
  
        return validation_error(
          'l_t_pd_d_2',
          'something_went_wrong',
          validation_errors,
          GlobalConstant::ErrorAction.default
        ) if validation_errors.present?
        
        url_path = create_request_path(@deal_fields_endpoint)
        
        custom_params = {
          name: field_name,
          field_type: "enum",
          options: options_array
        }
        r = send_request_of_type('post', url_path, custom_params)
        return r unless r.success?
        
        success_with_data(
          {
            name: r[:data]['name'],
            key: r[:data]['key']
          })
      end
      
    end

  end

end
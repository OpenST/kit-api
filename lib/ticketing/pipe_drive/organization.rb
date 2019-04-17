module Ticketing
  
  module PipeDrive
    
    class Organization < Ticketing::PipeDrive::Base
      
      # Initialize
      #
      # * Author: Dhananjay
      # * Date: 16/04/2019
      # * Reviewed By: Kedar
      #
      # @return [Ticketing::PipeDrive::Organization]
      #
      def initialize
        super

        @organizations_endpoint = "/#{@api_version}/organizations"
      end

      # Create an organization
      #
      # * Author: Dhananjay
      # * Date: 16/04/2019
      # * Reviewed By:
      #
      # @params [String] org_name (mandatory) - organization name
      #
      # @return [Result::Base]
      #
      def create(org_name)
        validation_errors = []
  
        validation_errors.push('invalid_org_name') unless Util::CommonValidator.is_string?(org_name)
  
        return validation_error(
          'l_t_pd_o_1',
          'something_went_wrong',
          validation_errors,
          GlobalConstant::ErrorAction.default
        ) if validation_errors.present?
        
        url_path = create_request_path(@organizations_endpoint)
        custom_params = {
          name: org_name
        }
  
        r = send_request_of_type('post', url_path, custom_params)
        return r unless r.success?
        
        success_with_data(
          {
            org_id: r[:data]['id']
          })
      end
    
    end
  
  end

end
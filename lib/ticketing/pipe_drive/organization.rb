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

        # TODO - Dhananjay - add api params validations
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
        url_path = create_request_path(@organizations_endpoint)
        custom_params = {
          name: org_name
        }
  
        r = send_request_of_type('post', url_path, custom_params)
        return r unless r.success?

        # TODO - Dhananjay - change following
        success_with_data({
                            org_id: ''
                          })
      end
    
    end
  
  end

end
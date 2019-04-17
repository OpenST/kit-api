module Ticketing
  
  module PipeDrive
    
    class Person < Ticketing::PipeDrive::Base
      
      # Initialize
      #
      # * Author: Dhananjay
      # * Date: 16/04/2019
      # * Reviewed By: Kedar
      #
      # @return [Ticketing::PipeDrive::Person]
      #
      def initialize
        super

        # TODO - Dhananjay - add api params validations
        @persons_endpoint = "/#{@api_version}/persons"
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
      # @return [Result::Base]
      #
      def create(first_name, last_name, email, org_id)
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
    
    end
  
  end

end
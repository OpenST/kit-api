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
        validation_errors = []
  
        validation_errors.push('invalid_first_name') unless Util::CommonValidator.is_string?(first_name)
        validation_errors.push('invalid_last_name') unless Util::CommonValidator.is_string?(last_name)
        validation_errors.push('invalid_email') unless Util::CommonValidator.is_string?(email)
        validation_errors.push('invalid_org_id') unless Util::CommonValidator.is_integer?(org_id)
  
        return validation_error(
          'l_t_pd_p_1',
          'something_went_wrong',
          validation_errors,
          GlobalConstant::ErrorAction.default
        ) if validation_errors.present?
        
        url_path = create_request_path(@persons_endpoint)
        custom_params = {
          name: "#{first_name} #{last_name}",
          org_id: org_id,
          email: email
        }
        r = send_request_of_type('post', url_path, custom_params)
        return r unless r.success?
        
        success_with_data(
          {
            person_id: r[:data]['id'],
          })
      end
    
    end
  
  end

end
module Ticketing
  
  module PipeDrive
    
    class Pipeline < Ticketing::PipeDrive::Base
      
      # Initialize
      #
      # * Author: Dhananjay
      # * Date: 18/04/2019
      # * Reviewed By: Kedar
      #
      # @return [Ticketing::PipeDrive::Pipeline]
      #
      def initialize
        super
        
        @pipelines_endpoint = "/#{@api_version}/pipelines"
      end
      
      # Create an pipeline
      #
      # * Author: Dhananjay
      # * Date: 18/04/2019
      # * Reviewed By:
      #
      # @params [String] pipeline_name (mandatory) - pipeline name
      #
      # @return [Result::Base]
      #
      def create(pipeline_name)
        validation_errors = []
        
        validation_errors.push('invalid_pipeline_name') unless Util::CommonValidator.is_string?(pipeline_name)
        
        return validation_error(
          'l_t_pd_pl_1',
          'something_went_wrong',
          validation_errors,
          GlobalConstant::ErrorAction.default
        ) if validation_errors.present?
        
        url_path = create_request_path(@pipelines_endpoint)
        custom_params = {
          name: pipeline_name
        }
        
        r = send_request_of_type('post', url_path, custom_params)
        return r unless r.success?
        
        success_with_data(
          {
            pipeline_id: r[:data]['id']
          })
      end
    
    end
  
  end

end
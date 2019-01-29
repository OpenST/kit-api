module AdminManagement
  
  module Whitelist
  
    class Client < ServicesBase
    
      # Initialize
      #
      # * Author: Shlok
      # * Date: 14/09/2018
      # * Reviewed By:
      #
      # @param [String] email (mandatory) - Email
      #
      # @return [AdminManagement::Whitelist::Client]
      #
      def initialize(params)
        super
        @email = @params[:email]
        @client_id = nil
      end
    
      # Perform
      #
      # * Author: Shlok
      # * Date: 14/09/2018
      # * Reviewed By:
      #
      # @return [Result::Base]
      #
      def perform

        handle_errors_and_exceptions do

          validate_and_sanitize

          fetch_client

          find_or_create_client_whitelisting

          success

        end
    
      end
    
      private
      
      # Validate and sanitize
      #
      # * Author: Shlok
      # * Date: 14/09/2018
      # * Reviewed By:
      #
      # @return [Result::Base]
      #
      def validate_and_sanitize

        validate

        @email = @email.downcase.strip

        unless Util::CommonValidator.is_valid_email?(@email)
          fail OstCustomError.new validation_error(
            'um_w_d_1',
            'invalid_api_params',
            ['invalid_email'],
            GlobalConstant::ErrorAction.default
          )
        end

        success

      end

      # Fetch client for this email
      #
      # * Author: Puneet
      # * Date: 28/01/2019
      # * Reviewed By:
      #
      # Sets @client_id
      #
      # @return [Result::Base]
      #
      def fetch_client

        manager = Manager.where(email: @email).select(:current_client_id).first

        fail OstCustomError.new validation_error(
                                    'um_w_d_2',
                                    'invalid_api_params',
                                    ['invalid_email'],
                                    GlobalConstant::ErrorAction.default
                                ) if manager.blank?

        @client_id = manager.current_client_id

      end

      # Find or create record
      #
      # * Author: Shlok
      # * Date: 14/09/2018
      # * Reviewed By:
      #
      # @return [Result::Base]
      #
      def find_or_create_client_whitelisting
  
        wd = ClientWhitelisting.where(client_id: @client_id).first
        
        unless wd.present?
          ClientWhitelisting.create!(client_id: @client_id)
        end
  
        success

      end
      
    end
    
  end

end
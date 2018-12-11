module AdminManagement
  
  module Whitelist
  
    class Email < ServicesBase
    
      # Initialize
      #
      # * Author: Dhananjay
      # * Date: 14/09/2018
      # * Reviewed By: Sunil Khedar
      #
      # @param [String] email (mandatory) - Email to be whitelisted
      #
      # @return [AdminManagement::Whitelist::Email]
      #
      def initialize(params)
        super

        @email = @params[:email]
      end
    
      # Perform
      #
      # * Author: Dhananjay
      # * Date: 14/09/2018
      # * Reviewed By: Sunil Khedar
      #
      # @return [Result::Base]
      #
      def perform
      
        handle_errors_and_exceptions do

          validate_and_sanitize

          find_or_create_whitelisted_email

          success

        end
    
      end
    
      private
      
      # Validate and sanitize
      #
      # * Author: Dhananjay
      # * Date: 14/09/2018
      # * Reviewed By: Sunil Khedar
      #
      # @return [Result::Base]
      #
      def validate_and_sanitize

        validate

        @email = @email.downcase.strip

        unless Util::CommonValidator.is_valid_email?(@email)
          fail OstCustomError.new validation_error(
            'um_w_e_1',
            'invalid_api_params',
            ['invalid_email'],
            GlobalConstant::ErrorAction.default
          )
        end
  
        success

      end

      # Find or create Whitelisted Email
      #
      # * Author: Dhananjay
      # * Date: 14/09/2018
      # * Reviewed By: Sunil Khedar
      #
      # @return [Result::Base]
      #
      def find_or_create_whitelisted_email
  
        we = ClientWhitelisting.where(identifier: @email, kind: GlobalConstant::ClientWhitelisting.email_kind).first

        unless we.present?
          we = ClientWhitelisting.new
          we.identifier = @email
          we.kind = GlobalConstant::ClientWhitelisting.email_kind
          we.save!
        end
  
        success

      end
      
    end
    
  end

end
module AdminManagement
  
  module Whitelist
  
    class Domain < ServicesBase
    
      # Initialize
      #
      # * Author: Dhananjay
      # * Date: 14/09/2018
      # * Reviewed By: Sunil Khedar
      #
      # @param [String] email_domain (mandatory) - Email domain to be whitelisted
      #
      # @return [AdminManagement::Whitelist::Domain]
      #
      def initialize(params)
        super
      
        @email_domain = @params[:email_domain]

        @domain = nil
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

          find_or_create_whitelisted_domain

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

        @email_domain = @email_domain.downcase.strip

        unless Util::CommonValidator.is_valid_email_domain?(@email_domain)
          fail OstCustomError.new validation_error(
            'um_w_d_1',
            'invalid_api_params',
            ['invalid_email_domain'],
            GlobalConstant::ErrorAction.default
          )
        end

        # As email domain starts with @, remove the @ from domain. Example: @ost.com
        @domain = @email_domain.split('@')[1]
  
        success

      end

      # Find or create Whitelisted Domain
      #
      # * Author: Dhananjay
      # * Date: 14/09/2018
      # * Reviewed By: Sunil Khedar
      #
      # @return [Result::Base]
      #
      def find_or_create_whitelisted_domain
  
        wd = ClientWhitelisting.where(identifier: @domain, kind: GlobalConstant::ClientWhitelisting.domain_kind).first
        
        unless wd.present?
          wd = ClientWhitelisting.new
          wd.identifier = @domain
          wd.kind = GlobalConstant::ClientWhitelisting.domain_kind
          wd.save!
        end
  
        success

      end
      
    end
    
  end

end
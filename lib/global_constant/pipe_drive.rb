# frozen_string_literal: true
module GlobalConstant
  
  class PipeDrive
    
    class << self

      def api_token
        config[:api_token]
      end

      def ost_pipedrive_user_id
        config[:user_id]
      end
      
      def pipedrive_deal_enterprise_custom_field_key
        config[:pipedrive_deal_enterprise_custom_field]
      end

      def pipedrive_deal_mobile_app_custom_field_key
        config[:pipedrive_deal_mobile_app_custom_field]
      end
      
      def pipedrive_api_base_url
        'https://api.pipedrive.com'
      end
      
      def pipedrive_api_version
        'v1'
      end

      private
      
      def config
        GlobalConstant::Base.pipedrive
      end
    
    end
  
  end

end

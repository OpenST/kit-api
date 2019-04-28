# frozen_string_literal: true
module GlobalConstant
  
  class PipeDrive
    
    class << self

      def api_token
        config[:api_token]
      end

      def ost_pipedrive_enterprise_user_id
        config[:enterprise_user_id]
      end
      
      def ost_pipedrive_business_user_id
        config[:business_user_id]
      end
      
      def ost_platform_enterprise_stage_id
        config[:enterprise_stage_id]
      end
      
      def ost_platform_business_stage_id
        config[:business_stage_id]
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

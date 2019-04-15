# frozen_string_literal: true
module GlobalConstant
  
  class UsageReportRecipient
    
    class << self
      
      def email_ids
        config[:email_ids]
      end
      
      private
      
      def config
        GlobalConstant::Base.usage_report_recipients_config
      end
    
    end
  
  end

end

# frozen_string_literal: true
module GlobalConstant

  class CompanyWeb < GlobalConstant::Base

    class << self

      def domain
        config['domain']
      end

      private

      def config
        GlobalConstant::Base.company_web_config
      end

    end

  end

end

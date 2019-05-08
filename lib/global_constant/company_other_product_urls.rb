# frozen_string_literal: true
module GlobalConstant

  class CompanyOtherProductUrls < GlobalConstant::Base

    class << self

      def view_root_url
        config['view_root_url']
      end

      private

      def config
        GlobalConstant::Base.company_other_product_urls
      end

    end

  end

end

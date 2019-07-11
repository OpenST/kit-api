# frozen_string_literal: true
module GlobalConstant

  class Google

    class << self

      def usage_report_spreadsheet_id
        config[:usage_report_spreadsheet_id]
      end

      private

      def config
        GlobalConstant::Base.google
      end

    end
  end
end

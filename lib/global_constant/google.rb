# frozen_string_literal: true
module GlobalConstant

  class Google

    class << self

      def usage_report_spreadsheet_id
        config[:usage_report_spreadsheet_id]
      end

      def private_key
        config[:private_key]
      end

      def client_email
        config[:client_email]
      end

      def project_id
        config[:project_id]
      end

      private

      def config
        GlobalConstant::Base.google
      end

    end
  end
end

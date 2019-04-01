# frozen_string_literal: true
module GlobalConstant

  class S3

    class << self

      def credentials
        @cdntials ||= {
            access_key: config['access_key'],
            secret_key: config['secret_key']
        }
      end

      def master_folder
        @mf ||= config['master_folder']
      end

      def reports_bucket
        @rb ||= config['reports_bucket']
      end

      def analytics_bucket
        @ab ||= config['analytics_bucket']
      end

      def platform_usage_reports_folder
        @purf ||= "#{self.master_folder}/#{config['platform_usage_reports_folder']}"
      end

      def analytics_graphs_folder
        @agf ||= "#{self.master_folder}/#{config['analytics_graphs_folder']}"
      end

      private

      def config
        GlobalConstant::Base.s3
      end

    end

  end

end

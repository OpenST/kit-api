# frozen_string_literal: true
module GlobalConstant

  class S3

    class << self

      def domain
        @dm ||= config['domain']
      end

      def master_folder
        @mf ||= config['master_folder']
      end

      def private_bucket_credentials
        @private_bucket_cdntials ||= {
            access_key: private_bucket_config['access_key'],
            secret_key: private_bucket_config['secret_key']
        }
      end

      def public_bucket_credentials
        @public_bucket_cdntials ||= {
            access_key: public_bucket_config['access_key'],
            secret_key: public_bucket_config['secret_key']
        }
      end

      def reports_bucket
        @rb ||= private_bucket_config['reports_bucket']
      end

      def analytics_bucket
        @ab ||= private_bucket_config['analytics_bucket']
      end

      def platform_usage_reports_folder
        @purf ||= "#{self.master_folder}/#{private_bucket_config['platform_usage_reports_folder']}"
      end

      def analytics_graphs_folder
        @agf ||= "#{self.master_folder}/#{private_bucket_config['analytics_graphs_folder']}"
      end

      def public_bucket
        @pb ||= public_bucket_config['bucket']
      end

      def test_economy_qr_code_folder
        @teqrcf ||= "#{self.master_folder}/#{public_bucket_config['test_economy_qr_code_folder']}"
      end

      def private_access
        'private'
      end

      def public_access
        'public'
      end

      def public_asset_s3_url(file_path)
        "#{GlobalConstant::S3.domain}/#{GlobalConstant::S3.public_bucket}/#{file_path}"
      end

      private

      def config
        GlobalConstant::Base.s3
      end

      def private_bucket_config
        config[private_access]
      end

      def public_bucket_config
        config[public_access]
      end

    end

  end

end

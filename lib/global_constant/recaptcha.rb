# frozen_string_literal: true
module GlobalConstant

  class Recaptcha

    class << self

      def site_key
        config[:site_key]
      end

      def secret_key
        config[:secret_key]
      end

      def skip?(params)
        !GlobalConstant::Environment.is_production_env? &&
            params['automation_test_token'] == 'lkashfiouqheinsdioqinsoidfhiondoi09239hnw903n903'
      end

      private

      def config
        GlobalConstant::Base.recaptcha_config
      end

    end

  end

end

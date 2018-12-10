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

      private

      def config
        GlobalConstant::Base.recaptcha_config
      end

    end

  end

end

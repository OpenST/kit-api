# frozen_string_literal: true
module GlobalConstant

  class ManagerDevice

    class << self

      ### Status Start ###

      def authorized
        'authorized'
      end

      def un_authorized
        'un_authorized'
      end

      # 30 day expiry
      def device_expiration_time
        30 * 24 * 60 * 60
      end

      ### Status End ###

      ### Fingerprint types ###

      def fingerprint_js
        'fingerprint_js'
      end

      def browser_agent
        'browser_agent'
      end

    end

  end

end
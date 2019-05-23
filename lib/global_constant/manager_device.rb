# frozen_string_literal: true
module GlobalConstant

  class ManagerDevice

    class << self

      ### Status Start ###

      def active_status
        'active'
      end

      def inactive_status
        'inactive_status'
      end

      def device_expiration_time
        30 * 24 * 60 * 60
      end

      ### Status End ###

    end

  end

end
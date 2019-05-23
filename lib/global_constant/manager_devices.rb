# frozen_string_literal: true
module GlobalConstant
  class ManagerDevice

    class << self
      ### status start ###

      def authorized_status
        'authorized_status'
      end

      def registered_status
        'registered_status'
      end

      ### status end ###
    end

    def device_expiration_time
      30 * 24 * 60 * 60
    end
  end
end
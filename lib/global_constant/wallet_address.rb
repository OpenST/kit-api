module GlobalConstant
  class WalletAddressStatus
    class << self
      def active_status
        'active'
      end

      def inactive_status
        'inactive'
      end
    end
  end
end
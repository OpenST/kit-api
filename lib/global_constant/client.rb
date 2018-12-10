# frozen_string_literal: true
module GlobalConstant

  class Client

    class << self

      ### Status Start ###

      def sandbox_active_status
        'sandbox_active'
      end

      def sandbox_inactive_status
        'sandbox_inactive'
      end

      def mainnet_active_status
        'mainnet_active'
      end

      def mainnet_inactive_status
        'mainnet_inactive'
      end

      ### Status End ###

      ### Properties Start ###

      def has_enforced_mfa_property
        'has_enforced_mfa'
      end

      ### Properties End ###

    end

  end

end

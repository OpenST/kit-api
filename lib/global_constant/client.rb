# frozen_string_literal: true
module GlobalConstant

  class Client

    class << self

      ### Status Start ###

      def sandbox_whitelisted_status
        'sandbox_whitelisted_status'
      end

      def sandbox_whitelist_requested_status
        'sandbox_whitelist_requested_status'
      end

      def mainnet_whitelisted_status
        'mainnet_whitelisted_status'
      end

      def mainnet_whitelist_requested_status
        'mainnet_whitelist_requested_status'
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

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

      def sandbox_test_economy_qr_code_uploaded_status
        'sandbox_test_economy_qr_code_uploaded_status'
      end

      def sandbox_registered_in_mappy_server_status
        'sandbox_registered_in_mappy_server_status'
      end

      def webhook_registered_in_mappy_server_status
        'webhook_registered_in_mappy_server_status'
      end

      def mainnet_whitelisted_status
        'mainnet_whitelisted_status'
      end

      def mainnet_whitelist_requested_status
        'mainnet_whitelist_requested_status'
      end

      def mainnet_test_economy_qr_code_uploaded_status
        'mainnet_test_economy_qr_code_uploaded_status'
      end

      def mainnet_registered_in_mappy_server_status
        'mainnet_registered_in_mappy_server_status'
      end

      ### Status End ###

      ### Properties Start ###

      def has_enforced_mfa_property
        'has_enforced_mfa'
      end

      def has_mobile_app_property
        'has_mobile_app'
      end

      def has_one_million_users_property
        'has_one_million_users'
      end

      def has_company_info_property
        'has_company_info'
      end

      ### Properties End ###

    end

  end

end

# frozen_string_literal: true
module GlobalConstant

  class Cookie

    class << self

      def user_cookie_name
        'ost_kit_ca'
      end

      def last_used_env_cookie_name
        'ost_kit_luse'
      end

      def mainnet_env
        'mainnet'
      end

      def sandbox_env
        'testnet'
      end

      def password_auth_prefix
        'p'
      end

      def mfa_auth_prefix
        'm'
      end

      def mfa_auth_expiry
        1.hour
      end

      def password_auth_expiry
        15.minute
      end

      def last_used_env_cookie_expiry
        1.year
      end

    end

  end

end

# frozen_string_literal: true
module GlobalConstant

  class Client

    class << self

      ### Status Start ###

      def active_status
        'active'
      end

      def inactive_status
        'inactive'
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

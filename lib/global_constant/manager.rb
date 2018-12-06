# frozen_string_literal: true
module GlobalConstant

  class Manager

    class << self

      ### Status Start ###

      def active_status
        'active'
      end

      def incomplete_status
        'incomplete'
      end

      # when user is auto blocked by system in case of multiple failed login events
      def auto_blocked_status
        'auto_blocked'
      end

      ### Status End ###

      ### Properties start ###

      def has_setup_mfa_property
        'has_setup_mfa'
      end

      def has_verified_email_property
        'has_verified_email'
      end

      ### Properties stop ###

    end

  end

end

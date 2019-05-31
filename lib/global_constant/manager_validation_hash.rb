# frozen_string_literal: true
module GlobalConstant

  class ManagerValidationHash

    class << self

      ### Status Start ###

      def active_status
        'active'
      end

      def inactive_status
        'inactive'
      end

      def used_status
        'used'
      end

      ### Status End ###


      ### Kind Start ###

      def reset_password_kind
        'reset_password'
      end

      def double_optin_kind
        'double_optin'
      end

      def manager_invite_kind
        'manager_invite'
      end

      def device_verification_kind
        'device_verification'
      end

      def secure_data_access_kind
        'secure_data_access'
      end

      ### Kind End ###

      ########## expiry intervals ###########

      def reset_token_expiry_interval
        30.minutes
      end

      def invite_in_expiry_interval
        15.days
      end

      def double_opt_in_expiry_interval
        15.days
      end

      def device_verification_expiry_interval
        30.minutes
      end

      def secure_data_access_expiry_interval
        15.minutes
      end

      ########## Kinds ###########

    end

  end

end

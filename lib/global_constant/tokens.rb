# frozen_string_literal: true
module GlobalConstant

  class ClientToken

    class << self

      def not_deployed
        'notDeployed'
      end

      def deployment_started
        'deploymentStarted'
      end

      def deployment_completed
        'deploymentCompleted'
      end

      def deployment_failed
        'deploymentFailed'
      end

      def low_balance_email
        'low_balance_email'
      end

      def very_low_balance_email
        'very_low_balance_email'
      end

      def zero_balance_email
        'zero_balance_email'
      end

      def delayed_recovery_interval
        43200
      end

      def has_ost_managed_owner
        'hasOstManagedOwner'
      end

    end

  end

end

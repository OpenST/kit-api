# frozen_string_literal: true
module GlobalConstant
  class Workflow
    class << self

      # Workflow kind constants Start #
      def token_deploy
        'token_deploy'
      end

      def bt_stake_and_mint
        'bt_stake_and_mint'
      end

      def state_root_sync
        'state_root_sync'
      end

      def st_prime_stake_and_mint
        'st_prime_stake_and_mint'
      end

      def grant_eth_stake_currency
        'grant_eth_stake_currency'
      end

      def setup_user
        'setup_user'
      end

      def test
        'test'
      end

      def authorize_device
        'authorize_device'
      end

      def authorize_session
        'authorize_session'
      end

      def revoke_device
        'revoke_device'
      end

      def revoke_session
        'revoke_session'
      end

      def initiate_recovery
        'initiate_recovery'
      end

      def abort_recovery_by_owner
        'abort_recovery_by_owner'
      end

      def reset_recovery_owner
        'reset_recovery_owner'
      end

      def execute_recovery
        'execute_recovery'
      end

      def abort_recovery_by_recovery_controller
        'abort_recovery_by_recovery_controller'
      end

      def logout_sessions
        'logout_sessions'
      end

      def st_prime_redeem_and_unstake
        'st_prime_redeem_and_unstake'
      end

      def bt_redeem_and_unstake
        'bt_redeem_and_unstake'
      end

      def update_price_point
        'update_price_point'
      end

      # Workflow kind constants End #

      def in_progress
        'inProgress'
      end

      def completed
        'completed'
      end

      def failed
        'failed'
      end

      def completely_failed
        'completelyFailed'
      end

    end
  end
end

# frozen_string_literal: true
module GlobalConstant
  class Workflow
    class << self

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
# frozen_string_literal: true
module GlobalConstant
  class Workflow
    class << self

      def token_deploy
        'token_deploy'
      end

      def stake_and_mint
        'stake_and_mint'
      end

      def state_root_sync
        'state_root_sync'
      end

      def in_progress
        'in_progress'
      end

      def completed
        'completed'
      end

      def failed
        'failed'
      end

      def failed_complete
        'failed_complete'
      end

    end
  end
end
# frozen_string_literal: true
module GlobalConstant

  class StakeCurrency

    class << self

      ### Status Start ###

      def setup_in_progress_status
        'setup_in_progress'
      end

      def active_status
        'active'
      end

      def inactive_status
        'inactive'
      end

      ### Status End ###

    end

  end

end

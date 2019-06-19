# frozen_string_literal: true
module GlobalConstant

  class GraphConstants

    class << self

      #Duration Type Start
      def duration_type_day
        'day'
      end

      def duration_type_week
        'week'
      end

      def duration_type_month
        'month'
      end

      def duration_type_year
        'year'
      end
      #Duration Type End

      #Graph Type Start
      def total_transactions
        'total_transactions'
      end

      def total_transactions_by_name
        'total_transactions_by_name'
      end

      def total_transactions_by_type
        'total_transactions_by_type'
      end
      #Graph Type End

    end

  end

end

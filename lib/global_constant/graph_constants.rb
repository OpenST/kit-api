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
        'total-transactions'
      end

      def total_transactions_by_name
        'total-transactions-by-name'
      end

      def total_transactions_by_type
        'total-transactions-by-type'
      end
      #Graph Type End

      def all_graph_types
        [
          total_transactions,
          total_transactions_by_name,
          total_transactions_by_type
        ]
      end

      def all_duration_types
        [
          duration_type_day,
          duration_type_week,
          duration_type_month,
          duration_type_year
        ]
      end

    end

  end

end

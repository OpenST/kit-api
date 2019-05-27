# frozen_string_literal: true
module GlobalConstant

  class ConversionRates

    class << self

      # ***************** Token Links ****************************

      def ost_link
        'simple-token'
      end

      # *******************************************************

      # ***************** Currency symbols ****************************

      def usd_currency
        'USD'
      end

      def ost_currency
        'OST'
      end

      def usdc_currency
        'USDC'
      end

      def eur_currency
        'EUR'
      end

      # *******************************************************

      # ***************** Status ****************************

      def active_status
        'active'
      end

      def inactive_status
        'inactive'
      end

      def inprocess_status
        'in-process'
      end

      # *******************************************************
    end

  end

end
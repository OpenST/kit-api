module Formatter

  class StakeCurrencies

    include Util::ResultHelper

    # Initialize
    #
    # * Author: Anagha
    # * Date: 15/04/2019
    # * Reviewed By:
    #
    # @params [Hash] stake_currencies (mandatory) - Stake currencies
    #
    # @return [Formatter::StakeCurrencies]
    def initialize(stake_currencies)
      @stake_currencies = stake_currencies
    end

    # Perform
    #
    # * Author: Anagha
    # * Date: 15/05/2019
    # * Reviewed By:
    #
    # @return [Formatter::StakeCurrencies]
    def perform

      response = {}

      @stake_currencies.each do |symbol, stake_currency|

        r = validate_and_sanitize(stake_currency)
        return r unless r.success?

        response[symbol] = {
          name: stake_currency[:name],
          symbol: stake_currency[:symbol],
          decimal: stake_currency[:decimal],
          contract_address: stake_currency[:contract_address]
        }
      end

      response

    end

    # Fetch token details
    #
    #
    # * Author: Anagha
    # * Date: 15/05/2019
    # * Reviewed By:
    #
    # @return [Result::Base]
    def validate_and_sanitize(row)

      if row[:name].nil? || row[:symbol].nil? || row[:contract_address].nil? || row[:decimal].nil?
        return error_with_data(
          'l_f_sc_1',
          'something_went_wrong',
          GlobalConstant::ErrorAction.default)
      end

      success

    end

  end

end
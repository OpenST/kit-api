class CurrencyConversionRate < DbConnection::KitSaasSubenv

  include Util::ResultHelper

  enum base_currency: {
    GlobalConstant::ConversionRates.ost_currency => 1,
    GlobalConstant::ConversionRates.usdc_currency => 2
  }

  enum status: {
    GlobalConstant::ConversionRates.active_status => 1,
    GlobalConstant::ConversionRates.inactive_status => 2,
    GlobalConstant::ConversionRates.inprocess_status => 3
  }

  # Fetch data from db depending on chain id
  #
  # * Author: Shlok
  # * Date: 05/03/2019
  # * Reviewed By:
  #
  # @return [Hash]
  #
  def fetch_price_points(params)
    chain_id = params[:chain_id]
    data_to_cache = {}
    stake_currency_id_to_symbol_map = {}
    price_points_data = {}

    active_stake_currency_details = StakeCurrency.active_stake_currencies_by_symbol

    active_stake_currency_details.each do | symbol, details |
      stake_currency_id_to_symbol_map[details[:id]] = symbol
    end

    missing_stake_currency_id_to_symbol_map = stake_currency_id_to_symbol_map.deep_dup

    while missing_stake_currency_id_to_symbol_map.present?
      
      fresh_price_points_data = fetch_default_price_points(:stake_currency_id_to_symbol_map => missing_stake_currency_id_to_symbol_map,
                                                           :chain_id => chain_id)

      price_points_data.merge!(fresh_price_points_data)

      fresh_price_points_data.each do |symbol, _|
        missing_stake_currency_id_to_symbol_map.delete(active_stake_currency_details[symbol][:id])
      end
    end

    data_to_cache[chain_id] = price_points_data
    success_with_data(data_to_cache)
  end

  # Fetch data from db depending on base currencies.
  #
  # * Author: Ankit
  # * Date: 22/04/2019
  # * Reviewed By:
  #
  # @return [Hash]
  #
  def fetch_default_price_points(params)
    stake_currency_id_to_symbol_map = params[:stake_currency_id_to_symbol_map]
    chain_id = params[:chain_id] || nil
    data_to_return = {}

    stake_currency_ids_array = stake_currency_id_to_symbol_map.keys

    quote_currency_id = QuoteCurrency.symbols_to_details_cache[GlobalConstant::QuoteCurrency.USD][:id]

    records = ::CurrencyConversionRate.where(
      status: GlobalConstant::ConversionRates.active_status,
      stake_currency_id: stake_currency_ids_array,
      quote_currency_id: quote_currency_id
    ).order('timestamp desc').limit(10)

    if chain_id.present?
      records = records.where(chain_id: chain_id)
    end

    if records.length == 0
      fail "Base currency's record not found." #TEMP. Need to decide what should be the course of action if this happens.
    end

    records.each do |record|
      next if data_to_return[stake_currency_id_to_symbol_map[record.stake_currency_id]].present?
      data_to_return[stake_currency_id_to_symbol_map[record.stake_currency_id]] = {}
      quote_currency_symbol = QuoteCurrency.ids_to_details_cache[record.quote_currency_id][:symbol]
      data_to_return[stake_currency_id_to_symbol_map[record.stake_currency_id]][quote_currency_symbol] = record.conversion_rate.to_s
    end
    data_to_return
  end

end
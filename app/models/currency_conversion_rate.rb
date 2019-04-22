class CurrencyConversionRate < DbConnection::KitSaasSubenv

  include Util::ResultHelper

  enum base_currency: {
    GlobalConstant::ConversionRates.ost_currency => 1,
    GlobalConstant::ConversionRates.usdc_currency => 2
  }

  enum quote_currency: {
    GlobalConstant::ConversionRates.usd_currency => 1
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
    base_currencies_array = CurrencyConversionRate.base_currencies.keys

    price_points_data = fetch_default_price_points(:base_currencies => base_currencies_array, :chain_id => chain_id)

    missing_base_currencies_array = base_currencies_array - price_points_data.keys
    data_to_cache[chain_id] = price_points_data

    while missing_base_currencies_array.length > 0 do
      fresh_price_points_data = fetch_default_price_points(:base_currencies => missing_base_currencies_array, :chain_id => chain_id)
      price_points_data = price_points_data.merge(fresh_price_points_data)
      missing_base_currencies_array = base_currencies_array - price_points_data.keys
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
    base_currencies = params[:base_currencies]
    chain_id = params[:chain_id] || nil
    data_to_return = {}

    records = ::CurrencyConversionRate.where(
      status: GlobalConstant::ConversionRates.active_status,
      base_currency: base_currencies,
      quote_currency: GlobalConstant::ConversionRates.usd_currency
    ).order('timestamp desc').limit(10)

    if chain_id.present?
      records = records.where(chain_id: chain_id)
    end

    if records.length == 0
      fail "base currency's record not found" #TEMP. Need to decide what should be the course of action if this happens.
    end

    records.each do |record|
      next if data_to_return[record.base_currency].present?
      data_to_return[record.base_currency] = {}
      data_to_return[record.base_currency][record.quote_currency] = record.conversion_rate.to_s
    end
    data_to_return
  end

end
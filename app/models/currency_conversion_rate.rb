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

  # Fetch data from db.
  #
  # * Author: Shlok
  # * Date: 05/03/2019
  # * Reviewed By:
  #
  # @return [Hash]
  #
  def fetch_price_points(params)
    chain_id = params[:chain_id]

    record = ::CurrencyConversionRate.where(["chain_id = ? AND status = ? AND quote_currency = ?", chain_id, 1, 1]).order('timestamp desc').first
    data_to_cache = {}
    data_to_cache[chain_id] = {}
    if record
      data_to_cache[chain_id][record.base_currency] = {}
      data_to_cache[chain_id][record.base_currency][record.quote_currency] = record.conversion_rate.to_s
    end
    success_with_data(data_to_cache)
  end

end
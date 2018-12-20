class CurrencyConversionRate < EstablishKitSaasSubenvSpecificDbConnection

  enum base_currency: {
    GlobalConstant::ConversionRates.ost_currency => 1
  }

  enum quote_currency: {
    GlobalConstant::ConversionRates.usd_currency => 1
  }

  enum status: {
    GlobalConstant::ConversionRates.active_status => 1,
    GlobalConstant::ConversionRates.inactive_status => 2,
    GlobalConstant::ConversionRates.inprocess_status => 3
  }

end
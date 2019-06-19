class SanitizePricePointData < DbMigrationConnection
  def up
    # run_migration_for_db(DbConnection::KitSaasSubenv) do
    #
    #   CurrencyConversionRate.where(quote_currency_id: nil).all.each do |r|
    #     r[:quote_currency_id] = r[:quote_currency]
    #     r.save!
    #   end
    #
    #   stake_currency = StakeCurrency.where(symbol: 'USDC').first
    #
    #   CurrencyConversionRate.where('stake_currency_id is NULL and conversion_rate > 1').all.each do |r|
    #     r[:stake_currency_id] = stake_currency[:id]
    #     r.save!
    #   end
    #
    #   CurrencyConversionRate.where('stake_currency_id is NULL and conversion_rate < 1').all.each do |r|
    #     r[:stake_currency_id] = 1
    #     r.save!
    #   end
    # end
  end

  def down

  end
end

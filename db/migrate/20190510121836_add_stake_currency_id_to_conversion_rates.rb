class AddStakeCurrencyIdToConversionRates < DbMigrationConnection
  def up
    run_migration_for_db(DbConnection::KitSaasSubenv) do
      add_column :currency_conversion_rates, :stake_currency_id, :bigint, after: :chain_id , null: true

      symbolToIdHash = []
      StakeCurrency.all.each do |row|
        symbolToIdHash.push(row.id)
      end

      CurrencyConversionRate.all.each do |row|
        puts row[:base_currency]
        row[:stake_currency_id] = (row[:base_currency] == 'OST' ? symbolToIdHash[0] : symbolToIdHash[1])
        row.save!
      end
    end
  end

  def down
    run_migration_for_db(DbConnection::KitSaasSubenv) do
      remove_column :currency_conversion_rates, :stake_currency_id
    end
  end
end



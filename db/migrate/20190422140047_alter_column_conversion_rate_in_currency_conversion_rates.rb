class AlterColumnConversionRateInCurrencyConversionRates < DbMigrationConnection
  def up
    run_migration_for_db(DbConnection::KitSaasSubenv) do
      change_table :currency_conversion_rates do |t|
        t.change(:conversion_rate, :decimal, precision: 21, scale: 10)
      end
    end
  end
  
  def down
    run_migration_for_db(DbConnection::KitSaasSubenv) do
      change_table :currency_conversion_rates do |t|
        t.change(:conversion_rate, :decimal, precision: 15, scale: 6)
      end
    end
  end

end
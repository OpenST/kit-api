class RemoveBaseCurrencyFromCurrencyConversionRates < DbMigrationConnection
  def up
    run_migration_for_db(DbConnection::KitSaasSubenv) do
      remove_index :currency_conversion_rates, name: 'cuk_1'
      remove_column :currency_conversion_rates, :base_currency
    end
  end

  def down
    run_migration_for_db(DbConnection::KitSaasSubenv) do
      add_column :currency_conversion_rates, :base_currency, :tinyint, limit: 1, null: false, after: :chain_id
      add_index :currency_conversion_rates, [:chain_id, :timestamp, :status, :base_currency, :quote_currency], unique: true, name: 'cuk_1'
    end
  end
end

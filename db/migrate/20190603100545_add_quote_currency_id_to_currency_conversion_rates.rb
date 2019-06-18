class AddQuoteCurrencyIdToCurrencyConversionRates < DbMigrationConnection
  def up
    run_migration_for_db(DbConnection::KitSaasSubenv) do
      add_column :currency_conversion_rates, :quote_currency_id, :tinyint, :null => true, :after => :stake_currency_id
    end
  end

  def down
    run_migration_for_db(DbConnection::KitSaasSubenv) do
      remove_column :currency_conversion_rates, :quote_currency_id
    end
  end
end

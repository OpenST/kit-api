class AddStakeCurrencyIdToConversionRates < DbMigrationConnection
  def up
    run_migration_for_db(DbConnection::KitSaasSubenv) do
      add_column :currency_conversion_rates, :stake_currency_id, :tinyint, after: :chain_id , null: true

      add_index :currency_conversion_rates, [:chain_id, :timestamp, :status, :stake_currency_id, :quote_currency], unique: true, name: 'cuk_2'
    end
  end

  def down
    run_migration_for_db(DbConnection::KitSaasSubenv) do
      remove_column :currency_conversion_rates, :stake_currency_id
    end
  end
end



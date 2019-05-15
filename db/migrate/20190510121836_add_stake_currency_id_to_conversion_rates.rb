class AddStakeCurrencyIdToConversionRates < DbMigrationConnection
  def up
    run_migration_for_db(DbConnection::KitSaasSubenv) do
      add_column :currency_conversion_rates, :stake_currency_id, :tinyint, after: :chain_id , null: true

    end
  end

  def down
    run_migration_for_db(DbConnection::KitSaasSubenv) do
      remove_column :currency_conversion_rates, :stake_currency_id
    end
  end
end



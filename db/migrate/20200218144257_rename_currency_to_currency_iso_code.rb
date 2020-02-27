class RenameCurrencyToCurrencyIsoCode < DbMigrationConnection
  def up
    run_migration_for_db(DbConnection::KitSaasRedemptionSubenv) do
      rename_column :countries, :currency, :currency_iso_code
    end
  end

  def down
    run_migration_for_db(DbConnection::KitSaasRedemptionSubenv) do
      rename_column :countries, :currency_iso_code, :currency
    end
  end
end

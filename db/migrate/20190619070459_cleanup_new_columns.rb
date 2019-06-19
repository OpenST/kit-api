class CleanupNewColumns < DbMigrationConnection
  def up
    run_migration_for_db(DbConnection::KitSaasSubenv) do
      change_column :currency_conversion_rates, :stake_currency_id, :tinyint, null: false
      change_column :currency_conversion_rates, :quote_currency_id, :tinyint, null: false
      #remove_column :currency_conversion_rates, :quote_currency
    end
  end

  def down

  end
end

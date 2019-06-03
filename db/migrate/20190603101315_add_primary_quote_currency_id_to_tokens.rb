class AddPrimaryQuoteCurrencyIdToTokens < DbMigrationConnection
  def up
    run_migration_for_db(DbConnection::KitSaasSubenv) do
      add_column :tokens, :primary_quote_currency_id, :tinyint, :null => true, :after => :stake_currency_id
    end
  end

  def down
    run_migration_for_db(DbConnection::KitSaasSubenv) do
      remove_column :tokens, :primary_quote_currency_id
    end
  end
end

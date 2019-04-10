class AddColumnStakeCurrencyIdInTokensTable < DbMigrationConnection
  def up

    run_migration_for_db(DbConnection::KitSaasSubenv) do
      add_column :tokens, :stake_currency_id, :tinyint, after: :delayed_recovery_interval, null: false
    end

  end

  def down
    run_migration_for_db(DbConnection::KitSaasSubenv) do
      remove_column :tokens, :stake_currency_id
    end
  end
end

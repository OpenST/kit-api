class AddDelayedRecoveryIntervalInTokens < DbMigrationConnection
  def up

    run_migration_for_db(DbConnection::KitSaasSubenv) do
      add_column :tokens, :delayed_recovery_interval, :integer, after: :decimal, null: false
    end

  end

  def down
    run_migration_for_db(DbConnection::KitSaasSubenv) do
      remove_column :tokens, :delayed_recovery_interval
    end
  end
end


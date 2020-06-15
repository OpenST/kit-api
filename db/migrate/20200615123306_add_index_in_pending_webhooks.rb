class AddIndexInPendingWebhooks < DbMigrationConnection
  def up
    run_migration_for_db(DbConnection::SaasBigSubenv) do
      add_index :pending_webhooks, [:next_retry_at, :status], name: 'nrs_1'
    end
  end

  def down
    run_migration_for_db(DbConnection::KitSaasRedemptionSubenv) do
      remove_index :pending_webhooks, name: 'nrs_1'
    end
  end
end

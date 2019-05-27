class CreateWebhookSubscriptionsTable < DbMigrationConnection
  def up

    run_migration_for_db(DbConnection::KitSaasSubenv) do

      create_table :webhook_subscriptions do |t|
        t.column :client_id, :integer, null: false
        t.column :topic, :tinyint, limit: 1, null: false
        t.column :webhook_endpoint_id, :tinyint, limit: 1, null: false
        t.column :status, :tinyint, null: false, limit: 1
        t.timestamps
      end

      add_index :webhook_subscriptions, [:client_id, :topic ,:webhook_endpoint_id], name: 'uk_1', unique: true
    end

  end

  def down
    run_migration_for_db(DbConnection::KitSaasSubenv) do

      drop_table :webhook_subscriptions if DbConnection::KitSaasSubenv.connection.table_exists? :webhook_subscriptions

    end
  end

end

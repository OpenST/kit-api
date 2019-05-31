class CreatePendingWebhooksTable < DbMigrationConnection
  def up

    run_migration_for_db(DbConnection::SaasBigSubenv) do

      create_table :pending_webhooks do |t|
        t.column :client_id, :integer, null: false
        t.column :event_uuid, :string, limit: 40, null: false
        t.column :webhook_topic_kind, :tinyint, limit: 1, null: false
        t.text :extra_data, default: nil
        t.column :status, :tinyint, null: false, limit: 1
        t.column :retry_count, :integer, default: 0
        t.integer :last_attempted_at, null: false
        t.text :mappy_error, default: nil, limit: 1000
        t.timestamps
      end

    end

  end

  def down
    run_migration_for_db(DbConnection::SaasBigSubenv) do

      drop_table :pending_webhooks if DbConnection::SaasBigSubenv.connection.table_exists? :pending_webhooks

    end
  end

end

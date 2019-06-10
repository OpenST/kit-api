class CreateWebhookQueuesTable < DbMigrationConnection
  def up

    run_migration_for_db(DbConnection::SaasSubenv) do

      create_table :webhook_queues do |t|
        t.column :cron_process_id, :integer, null: true
        t.column :chain_id, :integer, null: false
        t.column :queue_topic_suffix, :string, limit: 255, null: false
        t.column :status, :tinyint, null: false, limit: 1
        t.timestamps
      end

      add_index :webhook_queues, [:chain_id, :queue_topic_suffix], name: 'uk_1', unique: true
      add_index :webhook_queues, [:cron_process_id], name: 'uk_2', unique: true

    end

  end

  def down
    run_migration_for_db(DbConnection::SaasSubenv) do

      drop_table :webhook_queues if DbConnection::SaasSubenv.connection.table_exists? :webhook_queues

    end
  end

end

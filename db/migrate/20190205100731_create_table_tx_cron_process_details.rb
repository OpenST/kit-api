class CreateTableTxCronProcessDetails < DbMigrationConnection

  def up
    run_migration_for_db(DbConnection::SaasSubenv) do
      create_table :tx_cron_process_details do |t|
        t.column :cron_process_id, :integer, null: true
        t.column :chain_id, :integer, null: false
        t.column :queue_topic_suffix, :string, null: false
        t.timestamps
      end

      add_index :tx_cron_process_details, [:cron_process_id], name: "cron_process_id", unique:true
      add_index :tx_cron_process_details, [:chain_id, :queue_topic_suffix], name: "chain_queue_suffix_uniq", unique:true
    end
  end

  def down

    run_migration_for_db(DbConnection::SaasSubenv) do
      drop_table :tx_cron_process_details
    end

  end

end

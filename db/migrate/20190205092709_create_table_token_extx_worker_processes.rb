class CreateTableTokenExtxWorkerProcesses < DbMigrationConnection
  def up
    run_migration_for_db(DbConnection::SaasSubenv) do
      create_table :token_extx_worker_processes do |t|
        t.column :token_id, :integer, null: false
        t.column :tx_cron_process_detail_id, :integer, null: true
        t.column :token_address_id, :integer, null: false
        t.column :properties, :tinyint, limit: 2, null: false, default: 0
        t.timestamps
      end

      add_index :token_extx_worker_processes, [:token_id, :tx_cron_process_detail_id], name: "token_cron_process_uniq", unique:true
      add_index :token_extx_worker_processes, [:token_address_id], name: "token_address_uniq", unique:true
    end
  end

  def down

    run_migration_for_db(DbConnection::SaasSubenv) do
      drop_table :token_extx_worker_processes
    end

  end
end

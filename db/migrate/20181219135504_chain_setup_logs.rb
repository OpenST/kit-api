class ChainSetupLogs < DbMigrationConnection

  def up

    run_migration_for_db(DbConnection::SaasBigSubenv) do

      create_table :chain_setup_logs do |t|
        t.column :chain_id, :integer, null: false
        t.column :chain_kind, :tinyint, null: false, limit: 1
        t.column :step_kind, :tinyint, null: false, limit: 1
        t.column :debug_params, :text, null: false
        t.column :transaction_hash, :string, limit: 255, null: true
        t.column :status, :tinyint, null: false, limit: 1
        t.timestamps
      end

    end

  end

  def down
    run_migration_for_db(DbConnection::SaasBigSubenv) do
      drop_table :chain_setup_logs if DbConnection::SaasBigSubenv.connection.table_exists? :chain_setup_logs
    end
  end
  
end

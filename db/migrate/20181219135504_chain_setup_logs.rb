class ChainSetupLogs < DbMigrationConnection

  def up

    run_migration_for_db(EstablishSaasBigDbConnection) do

      create_table :chain_setup_logs do |t|
        t.column :chain_id, :integer, null: false
        t.column :kind, :tinyint, null: false, limit: 1
        t.column :debug_params, :text, null: false
        t.column :transaction_hash, :string, limit: 255, null: true
        t.timestamps
      end

    end

  end

  def down
    run_migration_for_db(EstablishSaasBigDbConnection) do
      drop_table :chain_setup_logs if EstablishSaasBigDbConnection.connection.table_exists? :chain_setup_logs
    end
  end
  
end

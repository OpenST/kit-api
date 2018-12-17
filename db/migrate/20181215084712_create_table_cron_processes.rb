class CreateTableCronProcesses < DbMigrationConnection
  def up
    run_migration_for_db(EstablishSaasConfigDbConnection) do
      create_table :cron_processes do |t|
        t.column :kind, :tinyint, limit: 1, null: false
        t.column :ip_address, :string, limit: 255, null: false
        t.column :chain_id, :string, limit: 255, :null => true
        t.column :params, :text, null: true
        t.column :status, :tinyint, limit: 1, null: false
        t.column :last_start_time, :datetime, null: true
        t.column :last_end_time, :datetime, null: true
        t.timestamps
      end
    end
  end

  def down
    run_migration_for_db(EstablishSaasConfigDbConnection) do
      drop_table :cron_processes
    end
  end
end

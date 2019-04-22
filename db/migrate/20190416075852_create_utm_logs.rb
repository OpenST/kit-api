class CreateUtmLogs < DbMigrationConnection
  def up
    run_migration_for_db(DbConnection::KitSaasBigSubenv) do
      create_table :utm_logs do |t|
        t.column :client_manager_id, :integer, null: false
        t.column :utm_source, :string, limit: 255, null:false
        t.column :utm_type, :string, limit: 255, null:true
        t.column :utm_medium, :string, limit: 255, null:true
        t.column :utm_term, :string, limit: 255, null:true
        t.column :utm_campaign, :string, limit: 255, null:true
        t.column :utm_content, :string, limit: 255, null:true
        t.timestamps
      end
    end
  end

  def down
    run_migration_for_db(DbConnection::KitSaasBigSubenv) do
      drop_table :utm_logs
    end
  end
end

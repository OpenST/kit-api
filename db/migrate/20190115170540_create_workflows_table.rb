class CreateWorkflowsTable < DbMigrationConnection
  def up
    run_migration_for_db(DbConnection::KitSaasSubenv) do
      create_table :workflows do |t|
        t.column :kind, :tinyint, limit: 1, null:false
        t.column :client_id, :integer, null: true
        t.column :status, :tinyint, limit: 1, null:false
        t.column :request_params, :text, null: true
        t.column :debug_params, :text, null: true
        t.timestamps
      end
    end
  end

  def down
    run_migration_for_db(DbConnection::KitSaasSubenv) do
      drop_table :workflows if DbConnection::KitSaasSubenv.connection.table_exists? :workflows
    end
  end
end
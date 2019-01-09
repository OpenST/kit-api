class ClientConfigGroups < DbMigrationConnection
  def up
    run_migration_for_db(DbConnection::SaasSubenv) do
      create_table :client_config_groups do |t|
        t.column :client_id, :integer, null: false
        t.column :chain_id, :integer, null: false
        t.column :group_id, :integer, null: false
        t.timestamps
      end
      add_index :client_config_groups, [:client_id], unique: true, name: 'idx_client_id'
    end
  end

  def down
    run_migration_for_db(DbConnection::SaasSubenv) do
      drop_table :client_config_groups if DbConnection::SaasSubenv.connection.table_exists? :client_config_groups
    end
  end
end
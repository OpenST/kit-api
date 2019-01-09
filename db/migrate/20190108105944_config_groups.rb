class ConfigGroups < DbMigrationConnection
  def up
    run_migration_for_db(DbConnection::SaasSubenv) do
      create_table :config_groups do |t|
        t.column :chain_id, :integer, null: false
        t.column :group_id, :integer, null: false
        t.column :is_available_for_allocation, :tinyint, null: false, default: 0
        t.timestamps
      end
      add_index :config_groups, [:chain_id, :group_id], unique: true, name: 'idx_chain_id_group_id'
    end
  end

  def down
    run_migration_for_db(DbConnection::SaasSubenv) do
      drop_table :config_groups if DbConnection::SaasSubenv.connection.table_exists? :config_groups
    end
  end
end
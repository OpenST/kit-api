class CreateGraphsDataTable < DbMigrationConnection
  def up
    run_migration_for_db(DbConnection::KitSaasSubenv) do
      create_table :graph_data do |t|
        t.column :token_id, :int, null: false
        t.column :graph_type, :tinyint, null: false
        t.column :duration_type, :tinyint, null: false
        t.column :data, :text, null: false
        t.timestamps
      end

      add_index :graph_data, [:token_id, :graph_type, :duration_type], name: 'uk_1', unique: true
    end
  end

  def down
    run_migration_for_db(DbConnection::KitSaasSubenv) do
      remove_index :graph_data, name: 'uk_1'
      drop_table :graph_data if DbConnection::KitSaasSubenv.connection.table_exists? :graph_data
    end
  end
end
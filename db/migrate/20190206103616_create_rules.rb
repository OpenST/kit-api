class CreateRules < DbMigrationConnection
  def up
    run_migration_for_db(DbConnection::KitSaasSubenv) do
      create_table :rules do |t|
        t.column :name, :string, null: false
        t.column :kind, :tinyint, limit: 1, null:false
        t.text :abi, null: false
        t.timestamps
      end
      add_index :rules, [:name], name: 'uk_name', unique: true
    end
  end
  
  def down
    run_migration_for_db(DbConnection::KitSaasSubenv) do
      drop_table :rules if DbConnection::KitSaasSubenv.connection.table_exists? :rules
    end
  end
end

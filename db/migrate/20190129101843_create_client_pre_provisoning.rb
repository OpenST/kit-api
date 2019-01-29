class CreateClientPreProvisoning < DbMigrationConnection

  def up

    run_migration_for_db(DbConnection::KitSaasSubenv) do
      create_table :client_pre_provisonings do |t|
        t.column :client_id, :integer, null: false
        t.text :config, default: nil
        t.timestamps
      end
      add_index :client_pre_provisonings, [:client_id], name: 'uk_1', unique: true
    end

  end

  def down
    run_migration_for_db(DbConnection::KitSaasSubEnv) do
      drop_table :client_pre_provisonings if DbConnection::KitSaasSubEnv.connection.table_exists? :client_pre_provisonings
    end
  end
  
end

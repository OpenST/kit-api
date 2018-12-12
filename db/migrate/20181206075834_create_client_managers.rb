class CreateClientManagers < DbMigrationConnection


  def up
    run_migration_for_db(EstablishKitClientDbConnection) do
      create_table :client_managers do |t|
        t.column :client_id, :integer, null: false
        t.column :manager_id, :integer, null: false
        t.column :privilages, :tinyint, limit: 1, null: true
        t.timestamps
      end
      add_index :client_managers, [:client_id, :manager_id], name: 'uk_1', unique: true
      execute ("ALTER TABLE manager_validation_hashes AUTO_INCREMENT = 6000")
    end
  end

  def down
    run_migration_for_db(EstablishKitClientDbConnection) do
      drop_table :client_managers if EstablishKitClientDbConnection.connection.table_exists? :client_managers
    end
  end

end

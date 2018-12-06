class CreateClientManagers < DbMigrationConnection


  def up
    run_migration_for_db(EstablishCompanyClientDbConnection) do
      create_table :client_managers do |t|
        t.column :clientId, :integer, null: false
        t.column :managerId, :integer, null: false
        t.column :mainnetPrivilages, :tinyint, limit: 1, null: false
        t.column :sandboxPrivilages, :tinyint, limit: 1, null: false
        t.timestamps
      end
      add_index :client_managers, [:clientId, :managerId], name: 'uk_1', unique: true
      execute ("ALTER TABLE manager_validation_hashes AUTO_INCREMENT = 6000")
    end
  end

  def down
    run_migration_for_db(EstablishCompanyClientDbConnection) do
      drop_table :client_managers if EstablishCompanyClientDbConnection.connection.table_exists? :client_managers
    end
  end

end

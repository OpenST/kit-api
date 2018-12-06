class CreateClients < DbMigrationConnection

  def up
    run_migration_for_db(EstablishCompanyClientDbConnection) do
      create_table :clients do |t|
        t.column :name, :string, null: true
        t.column :mainnetStatus, :tinyint, limit: 1, null: false
        t.column :sandboxStatus, :tinyint, limit: 1, null: false
        t.column :properties, :tinyint, limit: 1, null: false
        t.timestamps
      end
    end
  end

  def down
    run_migration_for_db(EstablishCompanyClientDbConnection) do
      drop_table :clients if EstablishCompanyClientDbConnection.connection.table_exists? :clients
    end
  end
  
end

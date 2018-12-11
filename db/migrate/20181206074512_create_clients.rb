class CreateClients < DbMigrationConnection

  def up
    run_migration_for_db(EstablishKitClientDbConnection) do
      create_table :clients do |t|
        t.column :name, :string, null: true
        t.column :mainnet_statuses, :tinyint, limit: 1, null: true
        t.column :sandbox_statuses, :tinyint, limit: 1, null: true
        t.column :properties, :tinyint, limit: 1, null: true
        t.timestamps
      end
      execute ("ALTER TABLE clients AUTO_INCREMENT = 10000")
    end
  end

  def down
    run_migration_for_db(EstablishKitClientDbConnection) do
      drop_table :clients if EstablishKitClientDbConnection.connection.table_exists? :clients
    end
  end
  
end

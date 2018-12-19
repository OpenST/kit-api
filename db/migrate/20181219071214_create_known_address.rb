class CreateKnownAddress < DbMigrationConnection

  def up
    run_migration_for_db(EstablishSaasBigDbConnection) do
      create_table :known_addresses do |t|
        t.column :client_id, :integer, null: true
        t.column :encryption_salt_id, :integer, null: true
        t.column :address_type, :tinyint, null: false, limit: 1
        t.column :uuid, :string, null: false
        t.column :name, :string
        t.column :ethereum_address, :string, limit: 255
        t.column :private_key, :text
        t.column :status, :tinyint, null: false, limit: 1
        t.timestamps
      end
    end
  end

  def down
    run_migration_for_db(EstablishSaasBigDbConnection) do
      drop_table :known_addresses if EstablishSaasBigDbConnection.connection.table_exists? :known_addresses
    end
  end
  
end

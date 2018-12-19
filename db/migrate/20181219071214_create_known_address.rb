class CreateKnownAddress < DbMigrationConnection

  def up

    run_migration_for_db(EstablishSaasBigDbConnection) do

      create_table :known_addresses do |t|
        t.column :client_id, :integer, null: true
        t.column :encryption_salt_id, :integer, null: true
        t.column :address_type, :tinyint, null: false, limit: 1
        t.column :uuid, :string, null: false #TODO: do we need uuid ?
        t.column :name, :string, limit: 255, null: true
        t.column :ethereum_address, :string, limit: 255
        t.column :private_key, :text
        t.column :status, :tinyint, null: false, limit: 1
        t.timestamps
      end

      add_index :known_addresses, [:ethereum_address], name: 'uk_1', unique: true

      execute ("ALTER TABLE known_addresses AUTO_INCREMENT = 70000")

    end

  end

  def down
    run_migration_for_db(EstablishSaasBigDbConnection) do
      drop_table :known_addresses if EstablishSaasBigDbConnection.connection.table_exists? :known_addresses
    end
  end
  
end

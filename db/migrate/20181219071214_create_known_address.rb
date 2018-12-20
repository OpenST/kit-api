class CreateKnownAddress < DbMigrationConnection

  def up

    run_migration_for_db(DbConnection::SaasSubenv) do

      create_table :known_addresses do |t|
        t.column :address, :string, limit: 255
        t.column :private_key, :text
        t.column :encryption_salt, :blob, null: false #kms_encrypted
        t.timestamps
      end

      add_index :known_addresses, [:address], name: 'uk_1', unique: true

      execute ("ALTER TABLE known_addresses AUTO_INCREMENT = 70000")

    end

  end

  def down
    run_migration_for_db(DbConnection::SaasSubenv) do
      drop_table :known_addresses if DbConnection::SaasSubenv.connection.table_exists? :known_addresses
    end
  end
  
end

class AlterClientWhitelisting < DbMigrationConnection

  def up

    run_migration_for_db(DbConnection::KitClient) do
      drop_table :client_whitelistings if DbConnection::KitClient.connection.table_exists? :client_whitelistings
    end

    run_migration_for_db(ClientWhitelisting) do
      create_table :client_whitelistings do |t|
        t.column :client_id, :integer, null: false
        t.timestamps
      end
      add_index :client_whitelistings, [:client_id], name: 'uk_1', unique: true
    end

  end

  def down
    run_migration_for_db(ClientWhitelisting) do
      drop_table :client_whitelistings if ClientWhitelisting.connection.table_exists? :client_whitelistings
    end
  end

end

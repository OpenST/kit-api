class CreateClientWhitelistings < DbMigrationConnection

  def up
    run_migration_for_db(DbConnection::KitClient) do
      create_table :client_whitelistings do |t|
        t.column :kind, :tinyint, limit: 1, null: false
        t.column :identifier, :string, limit: 255, null: false
        t.timestamps
      end
      add_index :client_whitelistings, [:kind, :identifier], name: 'uk_1', unique: true
    end
  end

  def down
    run_migration_for_db(DbConnection::KitClient) do
      drop_table :client_whitelistings if DbConnection::KitClient.connection.table_exists? :client_whitelistings
    end
  end

end

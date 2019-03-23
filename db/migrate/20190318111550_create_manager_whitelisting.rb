class CreateManagerWhitelisting < DbMigrationConnection

  def up

    run_migration_for_db(DbConnection::KitClient) do
      create_table :manager_whitelistings do |t|
        t.column :kind, :tinyint, limit: 1, null: false
        t.column :identifier, :string, limit: 255, null: false
        t.timestamps
      end
      add_index :manager_whitelistings, [:kind, :identifier], name: 'uk_1', unique: true
    end

    # create row for ost.com in DB
    AdminManagement::Whitelist::Domain.new(identifier: 'ost.com').perform

  end

  def down
    run_migration_for_db(DbConnection::KitClient) do
      drop_table :manager_whitelistings if DbConnection::KitClient.connection.table_exists? :manager_whitelistings
    end
  end
  
end

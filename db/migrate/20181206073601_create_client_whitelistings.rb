class CreateClientWhitelistings < DbMigrationConnection

  def up
    run_migration_for_db(EstablishCompanyClientDbConnection) do
      create_table :manager_whitelistings do |t|
        t.column :kind, :tinyint, limit: 1, null: false
        t.column :identifier, :tinyint, limit: 1, null: false
        t.timestamps
      end
    end
  end

  def down
    run_migration_for_db(EstablishCompanyClientDbConnection) do
      drop_table :manager_whitelistings if EstablishCompanyClientDbConnection.connection.table_exists? :manager_whitelistings
    end
  end

end

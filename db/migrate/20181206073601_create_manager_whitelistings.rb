class CreateManagerWhitelistings < DbMigrationConnection

  def up
    run_migration_for_db(EstablishCompanyManagerDbConnection) do
      create_table :manager_whitelistings do |t|
        t.column :kind, :tinyint, limit: 1, null: false
        t.column :identifier, :tinyint, limit: 1, null: false
        t.timestamps
      end
    end
  end

  def down
    run_migration_for_db(EstablishCompanyManagerDbConnection) do
      drop_table :manager_whitelistings if EstablishCompanyManagerDbConnection.connection.table_exists? :manager_whitelistings
    end
  end

end

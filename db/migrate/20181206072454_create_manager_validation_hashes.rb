class CreateManagerValidationHashes < DbMigrationConnection

  def up
    run_migration_for_db(EstablishCompanyManagerDbConnection) do
      create_table :manager_validation_hashes do |t|
        t.column :managerId, :integer, null: false
        t.column :clientId, :integer, null: true
        t.column :validationHash, :text, null: false
        t.column :kind, :tinyint, limit: 1, null: false
        t.column :failedUsageAttempts, :integer, null: true
        t.column :status, :tinyint, limit: 1, null: false
        t.timestamps
      end
    end
  end

  def down
    run_migration_for_db(EstablishCompanyManagerDbConnection) do
      drop_table :manager_validation_hashes if EstablishCompanyManagerDbConnection.connection.table_exists? :manager_validation_hashes
    end
  end

end

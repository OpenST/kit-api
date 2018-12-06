class CreateManagers < DbMigrationConnection

  def up
    run_migration_for_db(EstablishCompanyManagerDbConnection) do
      create_table :managers do |t|
        t.column :email, :string, null: false
        t.column :password, :text, null: false #encrypted
        t.column :defaultClientId, :integer, null: true
        t.column :loginSalt, :blob, null: true #encrypted
        t.column :mfaToken, :blob, null: true #encrypted
        t.column :lastLoginAt, :integer, null: false
        t.column :properties, :tinyint, null: true
        t.column :failedLoginAttemptCount, :integer, null: true
        t.column :status, :tinyint, limit: 1, null: false
        t.timestamps
      end
    end
  end

  def down
    run_migration_for_db(EstablishCompanyManagerDbConnection) do
      drop_table :managers if EstablishCompanyManagerDbConnection.connection.table_exists? :managers
    end
  end

end

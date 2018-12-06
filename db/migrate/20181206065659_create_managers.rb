class CreateManagers < DbMigrationConnection

  def up
    run_migration_for_db(EstablishCompanyClientDbConnection) do
      create_table :managers do |t|
        t.column :email, :string, null: false
        t.column :password, :text, null: false #encrypted
        t.column :mfa_token, :blob, null: true #encrypted
        t.column :authentication_salt, :blob, null: true #encrypted
        t.column :last_session_updated_at, :integer, null: false
        t.column :current_client_id, :integer, null: true
        t.column :properties, :tinyint, null: true
        t.column :failed_login_attempt_count, :integer, null: true
        t.column :status, :tinyint, limit: 1, null: false
        t.timestamps
      end
      execute ("ALTER TABLE managers AUTO_INCREMENT = 2500")
    end
  end

  def down
    run_migration_for_db(EstablishCompanyClientDbConnection) do
      drop_table :managers if EstablishCompanyClientDbConnection.connection.table_exists? :managers
    end
  end

end

class CreateApiCredentials < DbMigrationConnection

  def up
    run_migration_for_db(DbConnection::KitSaasSubenv) do
      create_table :api_credentials do |t|
        t.column :client_id, :integer, null: false
        t.column :api_key, :string, null: false
        t.column :api_secret, :text, null: false #encrypted
        t.column :api_salt, :blob, null: false #kms_encrypted
        t.column :expiry_timestamp, :integer, null: false
        t.timestamps
      end
      add_index :api_credentials, [:api_key], name: 'uk_1', unique: true
      add_index :api_credentials, [:client_id, :expiry_timestamp], unique: false, name: 'i_1'
      execute ("ALTER TABLE api_credentials AUTO_INCREMENT = 500000")
    end
  end

  def down
    run_migration_for_db(DbConnection::KitSaasSubenv) do
      drop_table :api_credentials if DbConnection::KitSaasSubenv.connection.table_exists? :api_credentials
    end
  end
  
end

class CreateEncryptionSalt < DbMigrationConnection

  def up
    run_migration_for_db(DbConnection::SaasSubenv) do
      create_table :encryption_salts do |t|
        t.column :client_id, :integer, null: true
        t.column :kind, :tinyint, limit: 1, null: false
        t.column :salt, :blob, null: false #kms_encrypted
        t.timestamps
      end
    end
  end

  def down
    run_migration_for_db(DbConnection::SaasSubenv) do
      drop_table :encryption_salts if DbConnection::SaasSubenv.connection.table_exists? :encryption_salts
    end
  end

end

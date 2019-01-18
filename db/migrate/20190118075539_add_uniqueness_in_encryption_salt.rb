class AddUniquenessInEncryptionSalt < DbMigrationConnection

  def up
    run_migration_for_db(DbConnection::SaasSubenv) do
      change_column_null :encryption_salts, :client_id, false, 0
      add_index :encryption_salts, [:client_id, :kind], name: 'uk_1', unique: true
    end
  end

  def down
    run_migration_for_db(DbConnection::SaasSubenv) do
      remove_index :encryption_salts, name: 'uk_1'
    end
  end

end

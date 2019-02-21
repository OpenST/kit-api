class RenameClientidToTokenidInEncryptionsSalts < DbMigrationConnection

  def up
    run_migration_for_db(DbConnection::SaasSubenv) do
      rename_column :encryption_salts, :client_id, :token_id
    end
  end

  def down
    run_migration_for_db(DbConnection::SaasSubenv) do
      rename_column :encryption_salts, :token_id, :client_id
    end
  end

end

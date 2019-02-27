class AlterTransactionMeta < DbMigrationConnection

  def up
    run_migration_for_db(DbConnection::SaasBigSubenv) do
      change_column_null :transaction_meta, :token_id, true
    end
  end

  def down
    run_migration_for_db(DbConnection::SaasBigSubenv) do
      change_column_null :transaction_meta, :token_id, false
    end
  end

end

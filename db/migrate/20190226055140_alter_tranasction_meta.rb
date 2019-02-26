class AlterTranasctionMeta < DbMigrationConnection

  def up
    run_migration_for_db(DbConnection::SaasBigSubenv) do
      change_column_null :transaction_meta, :receipt_status, true
    end
  end

  def down
    run_migration_for_db(DbConnection::SaasBigSubenv) do
      change_column_null :transaction_meta, :receipt_status, false
    end
  end

end

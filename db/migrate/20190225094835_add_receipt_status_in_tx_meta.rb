class AddReceiptStatusInTxMeta < DbMigrationConnection

  def up
    run_migration_for_db(DbConnection::SaasBigSubenv) do
      add_column :transaction_meta, :receipt_status, :tinyint, limit: 1, null: false, after: :status
    end
  end

  def down
    run_migration_for_db(DbConnection::SaasBigSubenv) do
      remove_column :transaction_meta, :receipt_status
    end
  end

end

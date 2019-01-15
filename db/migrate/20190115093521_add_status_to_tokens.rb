class AddStatusToTokens < DbMigrationConnection
  def up

    run_migration_for_db(DbConnection::KitSaasSubenv) do
      add_column :tokens, :status, :tinyint, after: :decimal, null: false, default: 1
    end

  end

  def down
    run_migration_for_db(DbConnection::KitSaasSubenv) do
      remove_column :tokens, :status
    end
  end
end

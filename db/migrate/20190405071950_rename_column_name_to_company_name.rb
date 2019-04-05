class RenameColumnNameToCompanyName < DbMigrationConnection
  def up
    run_migration_for_db(DbConnection::KitClient) do
      rename_column :clients, :name, :company_name
    end
  end

  def down
    run_migration_for_db(DbConnection::KitClient) do
      rename_column :clients, :company_name, :name
    end
  end
end

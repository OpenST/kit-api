class AddColumnProperties < DbMigrationConnection
  def up
    run_migration_for_db(DbConnection::KitSaasSubenv) do
      add_column :tokens, :properties, :tinyint, after: :status, null: true
    end
  end

  def down
    run_migration_for_db(DbConnection::KitSaasSubenv) do
      remove_column :tokens, :properties
    end
  end
end
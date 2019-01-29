class AddIndexClientIdWorkflows < DbMigrationConnection
  def up
    run_migration_for_db(DbConnection::KitSaasSubenv) do
      add_index :workflows, [:client_id], name: 'c_id_idx'
    end
  end

  def down
    run_migration_for_db(DbConnection::KitSaasSubenv) do
      remove_index :workflows, name: 'c_id_idx'
    end
  end
end
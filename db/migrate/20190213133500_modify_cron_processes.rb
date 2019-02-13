class ModifyCronProcesses < DbMigrationConnection
  def up
    run_migration_for_db(DbConnection::SaasSubenv) do
      remove_columns :cron_processes, :chain_id
    end
  end

  def down
    run_migration_for_db(DbConnection::SaasSubenv) do
      add_column :cron_processes, :chain_id, :string, limit: 255, :null => true

    end
  end
end

class ModifyCronProcesses < DbMigrationConnection
  def up
    run_migration_for_db(DbConnection::SaasSubenv) do
      add_column :cron_processes, :kind_name, :string, limit: 255, after: :kind, :null => true
      remove_columns :cron_processes, :chain_id
      change_column_null :cron_processes, :ip_address, true
    end
  end

  def down
    run_migration_for_db(DbConnection::SaasSubenv) do
      remove_columns :cron_processes, :kind_name
      add_column :cron_processes, :chain_id, :string, limit: 255, :null => true
      change_column_null :cron_processes, :ip_address, false
    end
  end
end

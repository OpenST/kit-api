class RenameClientPreProvisoningTable < DbMigrationConnection
  def up
    run_migration_for_db(DbConnection::KitSaasSubenv) do
      rename_table :client_pre_provisonings, :client_pre_provisionings
    end
  end

  def down
    run_migration_for_db(DbConnection::KitSaasSubenv) do
      rename_table :client_pre_provisionings, :client_pre_provisonings
    end
  end
end

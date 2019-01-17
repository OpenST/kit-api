class RenameStateRootCommitHistoryToStateRootCommit < DbMigrationConnection
  def up
    run_migration_for_db(DbConnection::SaasSubenv) do
      rename_table :state_root_commit_history, :state_root_commits
    end
  end

  def down
    run_migration_for_db(DbConnection::SaasSubenv) do
      rename_table :state_root_commits, :state_root_commit_history
    end
  end
end

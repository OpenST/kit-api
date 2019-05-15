class AddFailedMfaAttemptCountInManagers < DbMigrationConnection
  def up
    run_migration_for_db(DbConnection::KitClient) do
      add_column :managers , :failed_mfa_attempt_count, :tinyint, after: :failed_login_attempt_count, null: true
    end
  end

  def down
    run_migration_for_db(DbConnection::KitClient) do
      remove_column :managers, :failed_mfa_attempt_count
    end
  end

end

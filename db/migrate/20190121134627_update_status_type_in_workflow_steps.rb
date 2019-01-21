class UpdateStatusTypeInWorkflowSteps < DbMigrationConnection
  def up
    run_migration_for_db(DbConnection::KitSaasSubenv) do
      change_column :workflow_steps, :kind, :integer
    end
  end

  def down
    run_migration_for_db(DbConnection::KitSaasSubenv) do
      change_column :workflow_steps, :kind, :tinyint
    end
  end
end

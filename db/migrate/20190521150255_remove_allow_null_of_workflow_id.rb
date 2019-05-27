class RemoveAllowNullOfWorkflowId < DbMigrationConnection

  def change
    run_migration_for_db(DbConnection::KitSaasSubenv) do
      change_column :workflow_steps, :workflow_id, :integer, null: false
    end
  end

end

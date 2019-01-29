class AddResponseDataColumnWorkflows < DbMigrationConnection
  def up
    run_migration_for_db(DbConnection::KitSaasSubenv) do
      add_column :workflows, :response_data, :text, after: :request_params, null: true
      end
    end

  def down
    run_migration_for_db(DbConnection::KitSaasSubenv) do
      remove_column :workflows, :response_data
    end
  end
end
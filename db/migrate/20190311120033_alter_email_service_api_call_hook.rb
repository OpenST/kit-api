class AlterEmailServiceApiCallHook < DbMigrationConnection
  def up

    # truncate old table
    query = "TRUNCATE TABLE email_service_api_call_hooks;"
    DbConnection::KitSaasBigSubenv.connection.execute(query)

    run_migration_for_db(DbConnection::KitSaasBigSubenv) do
      add_column :email_service_api_call_hooks, :receiver_entity_id, :integer, after: :id, null: false
      add_column :email_service_api_call_hooks, :receiver_entity_kind, :tinyint, limit: 1, after: :receiver_entity_id,  null: false
      remove_column :email_service_api_call_hooks, :email
    end
  end

  def down
    run_migration_for_db(DbConnection::KitSaasBigSubenv) do
      add_column :email_service_api_call_hooks, :email, :text, after: :receiver_entity_kind, null: false
      remove_column :email_service_api_call_hooks, :receiver_entity_kind
      remove_column :email_service_api_call_hooks, :receiver_entity_id
    end
  end
end

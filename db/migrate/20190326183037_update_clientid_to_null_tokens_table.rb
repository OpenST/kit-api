class UpdateClientidToNullTokensTable < DbMigrationConnection
  def up

    run_migration_for_db(DbConnection::KitSaasSubenv) do
      add_column :tokens, :client_id_was, :integer, after: :status, null: true
      add_column :tokens, :debug, :string, after: :client_id_was, null: true
      change_column_null :tokens, :client_id, true
    end

  end

  def down
    run_migration_for_db(DbConnection::KitSaasSubenv) do
      remove_column :tokens, :client_id_was
      remove_column :tokens, :debug
      change_column_null :tokens, :client_id, false
    end
  end
end

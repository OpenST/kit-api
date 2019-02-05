class AllowNullTimestampInApiCredentials < DbMigrationConnection
  def up
    run_migration_for_db(DbConnection::KitSaasSubenv) do
      change_column_null :api_credentials, :expiry_timestamp, true
    end
  end

  def down
    run_migration_for_db(DbConnection::KitSaasSubenv) do
      change_column_null :api_credentials, :expiry_timestamp, false
    end
  end
end
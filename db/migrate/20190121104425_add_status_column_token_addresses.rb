class AddStatusColumnTokenAddresses < DbMigrationConnection
  def up
    run_migration_for_db(DbConnection::KitSaasSubenv) do
      add_column :token_addresses, :status, :integer, after: :address, default: 1, null: false
    end
  end

  def down
    run_migration_for_db(DbConnection::KitSaasSubenv) do
      remove_column :token_addresses, :status
    end
  end
end
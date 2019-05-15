class AddAddressesToStakeCurrencies < DbMigrationConnection

  def up
    run_migration_for_db(DbConnection::KitSaasSubenv) do
      add_column :stake_currencies, :addresses, :text, after: :constants, null: true
    end
  end

  def down
    run_migration_for_db(DbConnection::KitSaasSubenv) do
      remove_column :stake_currencies, :addresses
    end
  end
end

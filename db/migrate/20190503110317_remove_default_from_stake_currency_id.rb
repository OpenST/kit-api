class RemoveDefaultFromStakeCurrencyId < DbMigrationConnection
  def up
    run_migration_for_db(DbConnection::KitSaasSubenv) do
      change_column :tokens, :stake_currency_id, :integer, default: nil, null: false
    end
  end

  def down
    run_migration_for_db(DbConnection::KitSaasSubenv) do
      change_column :tokens, :stake_currency_id, :integer, null: false, :default => 1
    end
  end
end

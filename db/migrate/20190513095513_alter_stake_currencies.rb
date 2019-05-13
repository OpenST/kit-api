class AlterStakeCurrencies < DbMigrationConnection

  def up
    run_migration_for_db(DbConnection::KitSaasSubenv) do
      change_column :stake_currencies, :decimal, :integer, default: nil, null: true
      change_column :stake_currencies, :contract_address, :string, limit: 255, default: nil, null: true
    end
  end

  def down
    run_migration_for_db(DbConnection::KitSaasSubenv) do
      change_column :stake_currencies, :decimal,  :integer, null: false
      change_column :stake_currencies, :contract_address, :string, limit: 255, null: false
    end
  end

end

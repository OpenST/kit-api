class AddInternalCodeToStakeCurrency < DbMigrationConnection
  def up
    run_migration_for_db(DbConnection::KitSaasSubenv) do
      add_column :stake_currencies, :constants, :text, :null => false, :after => :contract_address
    end
  end

  def down
    run_migration_for_db(DbConnection::KitSaasSubenv) do
      remove_column :stake_currencies, :constants
    end
  end
end

class AddInternalCodeToStakeCurrency < DbMigrationConnection
  def up
    run_migration_for_db(DbConnection::KitSaasSubenv) do
      add_column :stake_currencies, :internal_code, :string, :limit => 3, :null => false, :after => :symbol
      add_column :stake_currencies, :constants, :text, :null => false, :after => :contract_address
    end
  end

  def down
    run_migration_for_db(DbConnection::KitSaasSubenv) do
      remove_column :stake_currencies, :internal_code
      remove_column :stake_currencies, :constants
    end
  end
end

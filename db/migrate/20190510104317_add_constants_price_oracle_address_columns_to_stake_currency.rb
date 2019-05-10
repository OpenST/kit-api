class AddConstantsPriceOracleAddressColumnsToStakeCurrency < DbMigrationConnection
  def up
    run_migration_for_db(DbConnection::KitSaasSubenv) do
      add_column :stake_currencies, :price_oracle_contract_address, :string, :limit => 255, :null => true, :after => :contract_address
      add_column :stake_currencies, :constants, :text, :null => false, :after => :price_oracle_contract_address
    end
  end

  def down
    run_migration_for_db(DbConnection::KitSaasSubenv) do
      remove_column :stake_currencies, :constants
      remove_column :stake_currencies, :price_oracle_contract_address
    end
  end
end
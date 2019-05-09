class AddInternalCodeToStakeCurrency < DbMigrationConnection
  def up
    run_migration_for_db(DbConnection::KitSaasSubenv) do
      add_column :stake_currencies, :internal_code, :string, :limit => 3, :null => false, :after => :symbol
    end
  end

  def down
    run_migration_for_db(DbConnection::KitSaasSubenv) do
      remove_column :stake_currencies, :internal_code
    end
  end
end

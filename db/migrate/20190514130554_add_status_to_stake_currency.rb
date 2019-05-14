class AddStatusToStakeCurrency < DbMigrationConnection

  def up
    run_migration_for_db(DbConnection::KitSaasSubenv) do
      add_column :stake_currencies, :status, :tinyint, after: :constants , null: false
    end
  end

  def down
    run_migration_for_db(DbConnection::KitSaasSubenv) do
      remove_column :stake_currencies, :status
    end
  end

end

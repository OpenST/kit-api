class AddColumnInRedemptionProducts < DbMigrationConnection
  def up
    run_migration_for_db(DbConnection::SaasSubenv) do
      add_column :redemption_products, :instructions, :text, after: :description, null: false
    end
  end

  def down
    run_migration_for_db(DbConnection::SaasSubenv) do
      remove_column :redemption_products, :instructions
    end
  end
end

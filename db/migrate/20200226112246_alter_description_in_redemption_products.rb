class AlterDescriptionInRedemptionProducts < DbMigrationConnection
  def up
    run_migration_for_db(DbConnection::KitSaasRedemptionSubenv) do
      change_column :redemption_products, :description, :string, limit: 1000, null: true
    end
  end

  def down
    run_migration_for_db(DbConnection::KitSaasRedemptionSubenv) do
      change_column :redemption_products, :description, :string, limit: 1000, null: false
    end
  end
end

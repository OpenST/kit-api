class AddIndexInRedemption < DbMigrationConnection
  def up
    run_migration_for_db(DbConnection::KitSaasRedemptionSubenv) do
      add_index :redemption_product_countries, [:redemption_product_id, :country_id], name: 'uk_1', unique: true
      add_index :token_redemption_products, [:token_id, :redemption_product_id], name: 'uk_1', unique: true
      add_index :user_redemptions, [:uuid], name: 'uk_1', unique: true
      add_index :user_redemptions, [:user_uuid], name: 'n_uk_1', unique: false
    end
  end

  def down
    run_migration_for_db(DbConnection::KitSaasRedemptionSubenv) do
      remove_index :redemption_product_countries, name: 'uk_1'
      remove_index :token_redemption_products, name: 'uk_1'
      remove_index :user_redemptions, name: 'uk_1'
      remove_index :user_redemptions, name: 'n_uk_1'
    end
  end
end
class CreateRedemptionProductCountries < DbMigrationConnection
  def up
    run_migration_for_db(DbConnection::KitSaasRedemptionSubenv) do
      create_table :redemption_product_countries do |t|
        t.column :redemption_product_id, :int, null: false
        t.column :country_id, :int, null: false
        t.column :redemption_options, :text, null: false
        t.timestamps
      end
    end
  end

  def down
    run_migration_for_db(DbConnection::KitSaasRedemptionSubenv) do
      drop_table :redemption_product_countries
    end
  end
end

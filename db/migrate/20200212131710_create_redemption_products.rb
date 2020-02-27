class CreateRedemptionProducts < DbMigrationConnection
  def up
    run_migration_for_db(DbConnection::KitSaasRedemptionSubenv) do
      create_table :redemption_products do |t|
        t.column :name, :string, limit: 255, null: false
        t.column :description, :string, limit: 1000, null: false
        t.column :image, :text, null: true
        t.column :status, :integer, limit: 1, null: false
        t.timestamps
      end
    end
  end

  def down
    run_migration_for_db(DbConnection::KitSaasRedemptionSubenv) do
      drop_table :redemption_products
    end
  end
end

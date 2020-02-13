class CreateRedemptionProducts < DbMigrationConnection
  def up
    run_migration_for_db(DbConnection::SaasSubenv) do
      create_table :redemption_products do |t|
        t.column :name, :string, limit: 255, null: false
        t.column :description, :string, limit: 1000, null: false
        t.column :image, :text, null: true
        t.column :denomination, :text, null: false
        t.column :expiry_in_days, :int, null: false
        t.column :status, :integer, limit: 1, null: false
        t.timestamps
      end
    end
  end

  def down
    run_migration_for_db(DbConnection::SaasSubenv) do
      drop_table :redemption_products
    end
  end
end

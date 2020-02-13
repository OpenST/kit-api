class CreateTokenRedemptionProducts < DbMigrationConnection
  def up
    run_migration_for_db(DbConnection::SaasSubenv) do
      create_table :token_redemption_products do |t|
        t.column :token_id, :int, null: false
        t.column :redemption_product_id, :integer, limit: 8, null: false
        t.column :name, :string, limit: 255, null: false
        t.column :description, :string, limit: 1000, null: false
        t.column :image, :text, null: false
        t.column :sequence_number, :integer, limit: 8, null: false
        t.column :status, :integer, limit: 1, null: false
        t.timestamps
      end
    end
  end

  def down
    run_migration_for_db(DbConnection::SaasSubenv) do
      drop_table :token_redemption_products
    end
  end
end

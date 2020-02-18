class CreateUserRedemption < DbMigrationConnection
  def up
    run_migration_for_db(DbConnection::KitSaasRedemptionSubenv) do
      create_table :user_redemptions do |t|
        t.column :uuid, :string, limit: 40, null: false
        t.column :user_uuid, :string, limit: 40, null: false
        t.column :token_redemption_product_id, :integer, limit: 8 , null: false
        t.column :transaction_uuid, :string, limit: 255, null: false
        t.column :amount, :decimal, precision:15, scale:6,  null: false
        t.column :currency, :integer, limit:1, null: false
        t.column :status, :integer, limit:1, null: false
        t.column :email_address, :text, null: true #encrypted
        t.timestamps
      end
    end
  end

  def down
    run_migration_for_db(DbConnection::KitSaasRedemptionSubenv) do
      drop_table :user_redemptions
    end
  end
end

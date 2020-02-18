class CreateRedemptionProducts < DbMigrationConnection
  def up
    run_migration_for_db(DbConnection::RedemptionSubenv) do
      create_table :products do |t|
        t.column :name, :string, limit: 255, null: false
        t.column :description, :string, limit: 1000, null: false
        t.column :image, :text, null: true
        t.column :status, :integer, limit: 1, null: false
        t.timestamps
      end
    end
  end

  def down
    run_migration_for_db(DbConnection::RedemptionSubenv) do
      drop_table :products
    end
  end
end

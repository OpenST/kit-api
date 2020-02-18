class CreateCountries < DbMigrationConnection
  def up
    run_migration_for_db(DbConnection::KitSaasRedemptionSubenv) do
      create_table :countries do |t|
        t.column :name, :string, limit: 40, null: false
        t.column :currency, :string, limit: 40, null: false
        t.column :conversions, :text, null: false
        t.timestamps
      end
    end
  end

  def down
    run_migration_for_db(DbConnection::KitSaasRedemptionSubenv) do
      drop_table :countries
    end
  end
end

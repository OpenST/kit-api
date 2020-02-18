class AddCountryIsoCodeInCountries < DbMigrationConnection
  def up
    run_migration_for_db(DbConnection::KitSaasRedemptionSubenv) do
      add_column :countries ,:country_iso_code, :string, limit: 3, null: false, after: :name
      add_index :countries, [:country_iso_code], unique: true, name: 'uk_1'
    end
  end

  def down
    run_migration_for_db(DbConnection::KitSaasRedemptionSubenv) do
      remove_index :countries, name: 'uk_1'
      remove_column :countries, :country_iso_code
    end
  end
end

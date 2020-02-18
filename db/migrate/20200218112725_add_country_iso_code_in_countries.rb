class AddCountryIsoCodeInCountries < DbMigrationConnection
  def up
    run_migration_for_db(DbConnection::KitSaasRedemptionSubenv) do
      add_column :countries ,:country_iso_code, :string, limit: 3, null: false, after: :name
    end
  end

  def down
    run_migration_for_db(DbConnection::SaasBigSubenv) do
      remove_column :country_iso_code
    end
  end
end

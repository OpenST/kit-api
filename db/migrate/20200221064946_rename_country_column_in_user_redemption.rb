class RenameCountryColumnInUserRedemption < DbMigrationConnection
  def up
    run_migration_for_db(DbConnection::KitSaasRedemptionSubenv) do
      rename_column :user_redemptions, :currency, :country_id
    end
  end

  def down
    run_migration_for_db(DbConnection::KitSaasRedemptionSubenv) do
      rename_column :user_redemptions, :country_id, :currency
    end
  end
end

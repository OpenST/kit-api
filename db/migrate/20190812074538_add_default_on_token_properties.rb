class AddDefaultOnTokenProperties < DbMigrationConnection
  def up
    run_migration_for_db(DbConnection::KitSaasSubenv) do

      Token.where(properties: nil).update_all("properties = 0")

      Rails.cache.clear

      change_column :tokens, :properties, :tinyint, null: false, default: 0
    end
  end

  def down
    run_migration_for_db(DbConnection::KitSaasSubenv) do
      change_column :tokens, :properties, :tinyint, null: true
    end
  end
end

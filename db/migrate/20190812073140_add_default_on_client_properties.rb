class AddDefaultOnClientProperties < DbMigrationConnection
  def up
    run_migration_for_db(DbConnection::KitClient) do

      Client.where(properties: nil).update_all("properties = 0")
      Client.where(mainnet_statuses: nil).update_all("mainnet_statuses = 0")
      Client.where(sandbox_statuses: nil).update_all("sandbox_statuses = 0")

      Rails.cache.clear

      change_column :clients, :properties, :tinyint, limit: 1, null:false, default: 0
      change_column :clients, :mainnet_statuses, :integer, null:false, default: 0
      change_column :clients, :sandbox_statuses, :integer, null:false, default: 0
    end
  end

  def down
    run_migration_for_db(DbConnection::KitClient) do
      change_column :clients, :properties, :tinyint, limit: 1, null: true
      change_column :clients, :mainnet_statuses, :integer, null: true
      change_column :clients, :sandbox_statuses, :integer, null: true
    end
  end
end

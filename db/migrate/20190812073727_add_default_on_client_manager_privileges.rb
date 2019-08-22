class AddDefaultOnClientManagerPrivileges < DbMigrationConnection
  def up
    run_migration_for_db(DbConnection::KitClient) do

      ClientManager.where(privileges: nil).update_all("privileges = 0")

      Rails.cache.clear

      change_column :client_managers, :privileges, :tinyint, limit: 1, null: false, default: 0
    end
  end

  def down
    run_migration_for_db(DbConnection::KitClient) do
      change_column :client_managers, :privileges, :tinyint, limit: 1, null: true
    end
  end
end

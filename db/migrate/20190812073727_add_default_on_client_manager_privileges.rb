class AddDefaultOnClientManagerPrivileges < DbMigrationConnection
  def up
    run_migration_for_db(DbConnection::KitClient) do

      ClientManager.where(privileges: nil).each do |client_manager|
        client_manager[:privileges] = 0
        client_manager.save!
      end

      change_column :client_managers, :privileges, :tinyint, limit: 1, null: false, default: 0
    end
  end

  def down
    run_migration_for_db(DbConnection::KitClient) do
      change_column :client_managers, :privileges, :tinyint, limit: 1, null: true
    end
  end
end

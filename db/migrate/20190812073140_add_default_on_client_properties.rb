class AddDefaultOnClientProperties < DbMigrationConnection
  def up
    run_migration_for_db(DbConnection::KitClient) do

      Client.where(properties: nil).each do |client|
        client[:properties] = 0
        client.save!
      end

      Client.where(mainnet_statuses: nil).each do |client|
        client[:mainnet_statuses] = 0
        client.save!
      end

      Client.where(sandbox_statuses: nil).each do |client|
        client[:sandbox_statuses] = 0
        client.save!
      end

      change_column :clients, :properties, :tinyint, limit: 1, null:false, default: 0
      change_column :clients, :mainnet_statuses, :tinyint, limit: 1, null:false, default: 0
      change_column :clients, :sandbox_statuses, :tinyint, limit: 1, null:false, default: 0
    end
  end

  def down
    run_migration_for_db(DbConnection::KitClient) do
      change_column :clients, :properties, :tinyint, limit: 1, null: true
      change_column :clients, :mainnet_statuses, :tinyint, limit: 1, null: true
      change_column :clients, :sandbox_statuses, :tinyint, limit: 1, null: true
    end
  end
end

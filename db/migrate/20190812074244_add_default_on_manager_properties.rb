class AddDefaultOnManagerProperties < DbMigrationConnection
  def up
    run_migration_for_db(DbConnection::KitClient) do
      change_column :managers, :properties, :tinyint, null: false, default: 0
    end
  end

  def down
    run_migration_for_db(DbConnection::KitClient) do
      change_column :managers, :properties, :tinyint, null: true
    end
  end
end

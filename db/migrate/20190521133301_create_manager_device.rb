class CreateManagerDevice < DbMigrationConnection
  def up
    run_migration_for_db(DbConnection::KitClient) do
      create_table :manager_devices do |t|
        t.column :manager_id, :integer, null: false
        t.column :browser_fingerprint, :string, limit: 256, null: false
        t.column :unique_hash, :string, null: false
        t.column :last_logged_in_at, :datetime, null: false
        t.column :status, :tinyint, null: false
        t.timestamps
      end

      add_index :manager_devices, [:unique_hash], name: 'md_uk_1', unique: true
    end
  end

  def down
    run_migration_for_db(DbConnection::KitClient) do
      drop_table :manager_devices if DbConnection::KitClient.connection.table_exists? :manager_devices
    end
  end
end
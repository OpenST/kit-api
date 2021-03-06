class CreateManagerValidationHashes < DbMigrationConnection

  def up
    run_migration_for_db(DbConnection::KitClient) do
      create_table :manager_validation_hashes do |t|
        t.column :manager_id, :integer, null: false
        t.column :client_id, :integer, null: true
        t.column :validation_hash, :text, null: false
        t.column :kind, :tinyint, limit: 1, null: false
        t.column :status, :tinyint, limit: 1, null: false
        t.text :extra_data, default: nil
        t.timestamps
      end
      execute ("ALTER TABLE manager_validation_hashes AUTO_INCREMENT = 5000")
    end
  end

  def down
    run_migration_for_db(DbConnection::KitClient) do
      drop_table :manager_validation_hashes if DbConnection::KitClient.connection.table_exists? :manager_validation_hashes
    end
  end

end

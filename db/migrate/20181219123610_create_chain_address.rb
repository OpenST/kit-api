class CreateChainAddress < DbMigrationConnection

  def up

    run_migration_for_db(DbConnection::KitSaasSubenv) do

      create_table :chain_addresses do |t|
        t.column :chain_id, :integer, null: false
        t.column :chain_kind, :tinyint, null: false, limit: 1
        t.column :kind, :tinyint, null: false, limit: 1
        t.column :address, :string, limit: 255, null: false
        t.column :known_address_id, :integer, null: true
        t.timestamps
      end

      add_index :chain_addresses, [:chain_id, :kind, :address], name: 'uk_1', unique: true

      execute ("ALTER TABLE chain_addresses AUTO_INCREMENT = 50000")

    end

  end

  def down
    run_migration_for_db(DbConnection::KitSaasSubenv) do
      drop_table :chain_addresses if DbConnection::KitSaasSubenv.connection.table_exists? :chain_addresses
    end
  end
  
end

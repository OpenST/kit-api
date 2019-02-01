class CreateChainAddresses < DbMigrationConnection

  def up

    run_migration_for_db(DbConnection::KitSaasSubenv) do

      create_table :chain_addresses do |t|
        t.column :associated_aux_chain_id, :integer, null: false
        t.column :kind, :tinyint, null: false, limit: 1
        t.column :address, :string, limit: 255, null: false
        t.column :known_address_id, :integer, null: true
        t.column :deployed_chain_id, :integer, null: true
        t.column :deployed_chain_kind, :tinyint, null: true, limit: 1
        t.column :status, :tinyint, limit: 1, null:false
        t.timestamps
      end

      add_index :chain_addresses, [:associated_aux_chain_id, :kind, :address], name: 'uk_1', unique: true

      execute ("ALTER TABLE chain_addresses AUTO_INCREMENT = 50000")

    end

  end

  def down
    run_migration_for_db(DbConnection::KitSaasSubenv) do

      drop_table :chain_addresses if DbConnection::KitSaasSubenv.connection.table_exists? :chain_addresses

    end
  end

end

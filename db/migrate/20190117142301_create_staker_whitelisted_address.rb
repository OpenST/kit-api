class CreateStakerWhitelistedAddress < DbMigrationConnection

  def up
    run_migration_for_db(DbConnection::KitSaasSubenv) do
      create_table :staker_whitelisted_addresses do |t|
        t.column :token_id, :integer, null: false
        t.column :staker_address,  :string, limit: 255, null:false
        t.column :gateway_composer_address, :string, limit: 255, null:false
        t.column :status, :tinyint, limit: 1, null:false
        t.timestamps
      end
      add_index :staker_whitelisted_addresses, [:token_id, :staker_address, :status], unique: true, name: 'uk_1'
    end
  end

  def down
    run_migration_for_db(DbConnection::KitSaasSubenv) do
      drop_table :staker_whitelisted_addresses if DbConnection::KitSaasSubenv.connection.table_exists? :staker_whitelisted_addresses
    end
  end
  
end

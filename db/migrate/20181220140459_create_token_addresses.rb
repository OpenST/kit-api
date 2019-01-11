class CreateTokenAddresses < DbMigrationConnection
  def up
    run_migration_for_db(DbConnection::KitSaasSubenv) do
      create_table :token_addresses do |t|
        t.column :token_id, :integer, null: false
        t.column :kind, :tinyint, limit: 1, null:false
        t.column :address, :string, limit: 255, null:false
        t.column :known_address_id, :integer, null: true
        t.timestamps
      end
      add_index :token_addresses, [:token_id, :kind, :address], unique: true, name: 'cuk_1'
    end
  end
  
  def down
    run_migration_for_db(DbConnection::KitSaasSubenv) do
      drop_table :token_addresses if DbConnection::KitSaasSubenv.connection.table_exists? :token_addresses
    end
  end
end
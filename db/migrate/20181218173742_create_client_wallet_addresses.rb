class CreateClientWalletAddresses < DbMigrationConnection
  def up
    run_migration_for_db(EstablishKitSaasSharedDbConnection) do
      create_table :client_wallet_addresses do |t|
        t.column :client_id, :integer, null: false
        t.column :sub_environment, :tinyint, limit: 1, null: false
        t.column :address, :string, null: false
        t.column :status, :tinyint, limit: 1, null:false
        t.timestamps
      end
      add_index :client_wallet_addresses, [:address], name: 'uk_address', unique: true
      add_index :client_wallet_addresses, [:client_id, :sub_environment, :status], name: 'index_1'
    end
  end

  def down
    run_migration_for_db(EstablishKitSaasSharedDbConnection) do
      drop_table :client_wallet_addresses if EstablishKitSaasSharedDbConnection.connection.table_exists? :client_wallet_addresses
    end
  end
end
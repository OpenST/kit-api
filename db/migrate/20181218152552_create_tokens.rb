class CreateTokens < DbMigrationConnection
  def up
    run_migration_for_db(EstablishKitSaasSharedSubenvSpecificDbConnection) do
      create_table :tokens do |t|
        t.column :client_id, :integer, null: false, unique: true
        t.column :name, :string, null: false, unique: true
        t.column :symbol, :string, null: false, unique: true
        t.column :conversion_factor, :decimal, precision: 15, scale: 6, null: false
        t.column :decimal, :integer, :default => 18
        t.timestamps
      end
      execute ("ALTER TABLE tokens AUTO_INCREMENT = 1000")
      add_index :tokens, [:client_id], name: 'uk_client_id', unique: true
      add_index :tokens, [:name], name: 'uk_name', unique: true
      add_index :tokens, [:symbol], name: 'uk_symbol', unique: true
    end
  end

  def down
    run_migration_for_db(EstablishKitSaasSharedSubenvSpecificDbConnection) do
      drop_table :tokens if EstablishKitSaasSharedSubenvSpecificDbConnection.connection.table_exists? :tokens
    end
  end
end
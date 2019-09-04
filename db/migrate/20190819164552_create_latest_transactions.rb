class CreateLatestTransactions < DbMigrationConnection
  def up
    run_migration_for_db(DbConnection::KitSaasSubenv) do
      create_table :latest_transactions do |t|
        t.column :transaction_hash, :string, limit: 255, null: false
        t.column :chain_id, :int, null: false
        t.column :token_id, :int, null: false
        t.column :tx_fees_in_wei, :string, limit: 255, null: false
        t.column :token_amount_in_wei, :string, limit: 255, null: false
        t.column :created_ts, :int, null: false
        t.timestamps
      end

      add_index :latest_transactions, [:created_ts], name: 'idx_1'
    end
  end

  def down
    run_migration_for_db(DbConnection::KitSaasSubenv) do
      remove_index :latest_transactions, name: 'idx_1'
      drop_table :latest_transactions if DbConnection::KitSaasSubenv.connection.table_exists? :latest_transactions
    end
  end
end
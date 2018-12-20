class CreateCurrencyConversionRates < DbMigrationConnection
  def up
    run_migration_for_db(DbConnection::KitSaasSubenv) do
      create_table :currency_conversion_rates do |t|
        t.column :chain_id, :integer, null: false
        t.column :base_currency, :tinyint, limit: 1, null: false
        t.column :quote_currency, :tinyint, limit: 1, null: false
        t.column :conversion_rate, :decimal, precision: 15, scale: 6, null: false
        t.column :timestamp, :integer, null:false
        t.column :transaction_hash, :string
        t.column :status, :tinyint, limit: 1, null:false
        t.timestamps
      end
      add_index :currency_conversion_rates, [:chain_id, :timestamp, :status, :base_currency, :quote_currency], name: 'index_1'
    end
  end

  def down
    run_migration_for_db(DbConnection::KitSaasSubenv) do
      drop_table :currency_conversion_rates if DbConnection::KitSaasSubenv.connection.table_exists? :currency_conversion_rates
    end
  end
end
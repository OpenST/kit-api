class CreateQuoteCurrencies < DbMigrationConnection
  def up
    run_migration_for_db(DbConnection::KitSaasSubenv) do
      create_table :quote_currencies do |t|
        t.column :name, :string, null: false
        t.column :symbol, :string, null: false
        t.column :status, :tinyint, null: false
        t.timestamps
      end

      add_index :quote_currencies, [:symbol], name: 'uk_1'
    end
  end

  def down
    run_migration_for_db(DbConnection::KitSaasSubenv) do
      remove_index :quote_currencies, name: 'uk_1'
      drop_table :quote_currencies if DbConnection::KitSaasSubenv.connection.table_exists? :quote_currencies
    end
  end
end

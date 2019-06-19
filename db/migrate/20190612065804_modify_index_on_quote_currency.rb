class ModifyIndexOnQuoteCurrency < DbMigrationConnection
  def up
    run_migration_for_db(DbConnection::KitSaasSubenv) do
      remove_index :quote_currencies, name: 'uk_1'
      add_index :quote_currencies, [:symbol], name: 'uk_1', unique: true
    end
  end

  def down
    run_migration_for_db(DbConnection::KitSaasSubenv) do
      remove_index :quote_currencies, name: 'uk_1'
    end
  end
end

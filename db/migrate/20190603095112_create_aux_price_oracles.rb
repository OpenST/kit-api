class CreateAuxPriceOracles < DbMigrationConnection
  def up
    run_migration_for_db(DbConnection::KitSaasSubenv) do
      create_table :aux_price_oracles do |t|
        t.column :chain_id, :integer, null: false
        t.column :stake_currency_id, :tinyint, null: false
        t.column :quote_currency_id, :tinyint, null: false
        t.column :contract_address, :string, null: false
        t.column :status, :tinyint, null: false
        t.timestamps
      end

      add_index :aux_price_oracles, [:chain_id, :stake_currency_id, :quote_currency_id, :status], name: 'qc_uk_1', unique: true
    end
  end

  def down
    run_migration_for_db(DbConnection::KitSaasSubenv) do
      remove_index :aux_price_oracles, name: 'qc_uk_1'
      drop_table :aux_price_oracles if DbConnection::KitSaasSubenv.connection.table_exists? :aux_price_oracles
    end
  end
end

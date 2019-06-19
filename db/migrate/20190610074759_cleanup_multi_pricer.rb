class CleanupMultiPricer < DbMigrationConnection
  def up
    run_migration_for_db(DbConnection::KitSaasSubenv) do
      ChainAddresses.where(kind: [42, 45]).destroy_all

      change_column :tokens, :preferred_display_currency_id, :tinyint, null: false

      change_column :quote_currencies, :name, :string, null: false
      change_column :quote_currencies, :symbol, :string, null: false
      change_column :quote_currencies, :status, :tinyint, null: false

      change_column :aux_price_oracles, :chain_id, :integer, null: false
      change_column :aux_price_oracles, :stake_currency_id, :tinyint, null: false
      change_column :aux_price_oracles, :quote_currency_id, :tinyint, null: false
      change_column :aux_price_oracles, :contract_address, :string, null: false
      change_column :aux_price_oracles, :status, :tinyint, null: false

      remove_index :currency_conversion_rates, name: 'cuk_2'
      add_index :currency_conversion_rates, [:chain_id, :timestamp, :status, :stake_currency_id, :quote_currency_id], unique: true, name: 'cuk_1'

    end
  end

  def down

  end
end

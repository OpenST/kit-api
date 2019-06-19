class ChangeIndicesOnAuxPriceOracles < DbMigrationConnection
  def up
    run_migration_for_db(DbConnection::KitSaasSubenv) do
      remove_index :aux_price_oracles, name: 'qc_uk_1'
      add_index :aux_price_oracles, [:chain_id, :stake_currency_id, :quote_currency_id], name: 'qc_uk_1', unique: true
      add_index :aux_price_oracles, [:chain_id, :contract_address], name: 'qc_uk_2', unique: true
    end
  end

  def down
    run_migration_for_db(DbConnection::KitSaasSubenv) do
      remove_index :aux_price_oracles, name: 'qc_uk_1'
      remove_index :aux_price_oracles, name: 'qc_uk_2'
    end
  end
end
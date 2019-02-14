class AddColumnsDeployedChainIdToTokenAddress < DbMigrationConnection
  def up
    run_migration_for_db(DbConnection::KitSaasSubenv) do
      add_column :token_addresses, :deployed_chain_id, :integer, after: :address, null: true
      add_column :token_addresses, :deployed_chain_kind, :tinyint, limit: 1, after: :deployed_chain_id, null: true
      add_index :token_addresses, [:address, :deployed_chain_id], unique: true, name: 'cuk_2'
    end
  end

  def down
    run_migration_for_db(DbConnection::KitSaasSubenv) do
      remove_column :token_addresses, :deployed_chain_id
      remove_column :token_addresses, :deployed_chain_kind
    end
  end
end

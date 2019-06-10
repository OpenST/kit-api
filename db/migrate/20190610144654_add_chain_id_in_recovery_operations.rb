class AddChainIdInRecoveryOperations < DbMigrationConnection
  def up
    run_migration_for_db(DbConnection::SaasBigSubenv) do
      add_column :recovery_operations, :chain_id, :integer, after: :id, null: false, default: 0
      remove_index :recovery_operations, name: 'index_execute_after_blocks'
      add_index :recovery_operations, [:chain_id, :execute_after_blocks], name: 'index_chain_execute_after_blocks'
    end
  end

  def down
    run_migration_for_db(DbConnection::SaasBigSubenv) do
      remove_column :recovery_operations, :chain_id
      remove_index :recovery_operations, name: 'index_chain_execute_after_blocks'
      add_index :recovery_operations, [:execute_after_blocks], name: 'index_execute_after_blocks'
    end
  end
end

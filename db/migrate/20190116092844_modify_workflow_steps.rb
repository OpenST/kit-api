class ModifyWorkflowSteps < DbMigrationConnection
  def up
    run_migration_for_db(DbConnection::KitSaasSubenv) do
      add_column :workflow_steps, :workflow_id, :integer, after: :id
      remove_columns :workflow_steps, :client_id, :parent_id, :uuid, :chain_id
      change_column_null :workflow_steps, :status, true

      remove_index :workflow_steps, name: 'idx_tx_hash_chain_id'
      add_index :workflow_steps, [:workflow_id, :kind, :status], unique: true, name: 'cuk_wid_kind_status'
    end
  end

  def down
    run_migration_for_db(DbConnection::KitSaasSubenv) do
      remove_index :workflow_steps, name: 'cuk_wid_kind_status'

      change_column_null :workflow_steps, :status, false
      add_column :workflow_steps, :client_id, :integer, null: false
      add_column :workflow_steps, :parent_id, :integer
      add_column :workflow_steps, :uuid, :string, limit: 255
      add_index :workflow_steps, [:transaction_hash, :chain_id], unique: false, name: 'idx_tx_hash_chain_id'
      remove_column :workflow_steps, :workflow_id

    end
  end
end

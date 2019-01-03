class CreateWorkflowSteps < DbMigrationConnection
  def up
    run_migration_for_db(DbConnection::KitSaasSubenv) do
      create_table :workflow_steps do |t|
        t.column :kind, :tinyint, limit: 1, null:false
        t.column :client_id, :integer, null: false
        t.column :chain_id, :integer, null: false
        t.column :parent_id, :integer
        t.column :transaction_hash, :string, limit: 255
        t.column :uuid, :string, limit: 255
        t.column :status, :tinyint, limit: 1, null:false
        t.column :request_params, :string, limit: 255
        t.column :debug_params, :string, limit: 255
        t.timestamps
      end
      add_index :workflow_steps, [:transaction_hash, :chain_id], unique: false, name: 'idx_tx_hash_chain_id'
    end
  end

  def down
    run_migration_for_db(DbConnection::KitSaasSubenv) do
      drop_table :workflow_steps if DbConnection::KitSaasSubenv.connection.table_exists? :workflow_steps
    end
  end
end
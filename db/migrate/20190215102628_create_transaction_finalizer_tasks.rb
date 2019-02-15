class CreateTransactionFinalizerTasks < DbMigrationConnection
  def up
    run_migration_for_db(DbConnection::SaasSubenv) do
      create_table :transaction_finalizer_tasks do |t|
        t.column :chain_id, :integer, null: false
        t.column :block_number, :integer, null: false
        t.column :transaction_hashes,  :text, null:false
        t.column :status,  :tinyint, null:false
        t.column :debug_params,  :text, null:true
        t.timestamps
      end
    end
  end

  def down
    run_migration_for_db(DbConnection::SaasSubenv) do
      drop_table :transaction_finalizer_tasks if DbConnection::SaasSubenv.connection.table_exists? :transaction_finalizer_tasks
    end
  end
end

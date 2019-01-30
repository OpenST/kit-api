class CreateBlockParserPendingTasks < DbMigrationConnection
  def up
    run_migration_for_db(DbConnection::SaasSubenv) do
      create_table :block_parser_pending_tasks do |t|
        t.column :chain_id, :integer, null: false
        t.column :block_number, :integer, null: false
        t.column :transaction_hashes,  :text, null:false
        t.timestamps
      end
      add_index :block_parser_pending_tasks, [:block_number], name: 'blk_ind'
    end
  end

  def down
    run_migration_for_db(DbConnection::SaasSubenv) do
      drop_table :block_parser_pending_tasks if DbConnection::SaasSubenv.connection.table_exists? :block_parser_pending_tasks
    end
  end
end

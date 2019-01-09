class CreateStateRootCommitHistory < DbMigrationConnection
  def up
    run_migration_for_db(DbConnection::SaasSubenv) do
      create_table :state_root_commit_history do |t|
        t.column :source_chain_id, :integer, null: false
        t.column :target_chain_id, :integer, null: false
        t.column :block_number, :integer, null: false
        t.column :status, :string, limit: 255, null:false
        t.timestamps
      end
      add_index :state_root_commit_history, [:source_chain_id, :target_chain_id, :block_number], unique: true, name: 'cuk_1'
    end
  end

  def down
    run_migration_for_db(DbConnection::SaasSubenv) do
      drop_table :state_root_commit_history if DbConnection::SaasSubenv.connection.table_exists? :state_root_commit_history
    end
  end
end
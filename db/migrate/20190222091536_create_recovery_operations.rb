class CreateRecoveryOperations < DbMigrationConnection
  def up
    run_migration_for_db(DbConnection::SaasBigSubenv) do

      create_table :recovery_operations do |t|
        t.column :token_id, :integer, null: false
        t.column :user_id, :string, null: false
        t.column :kind, :tinyint, null: false
        t.column :workflow_id, :integer, null: false, default: 0
        t.column :execute_after_blocks, :integer, null: false, default: 0
        t.column :status, :tinyint, null: false
        t.timestamps
      end

      add_index :recovery_operations, [:token_id, :user_id], name: 'tid_uid_indx'
      add_index :recovery_operations, [:execute_after_blocks], name: 'index_execute_after_blocks'
    end
  end

  def down
    run_migration_for_db(DbConnection::SaasBigSubenv) do

      drop_table :recovery_operations

    end
  end
end

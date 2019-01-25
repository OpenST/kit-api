class AddUniqueHashInWorkflows < DbMigrationConnection
  def up
    run_migration_for_db(DbConnection::KitSaasSubenv) do
      add_column :workflows, :unique_hash, :string, :null => true, :after => :client_id
      add_index :workflows, [:unique_hash], unique: true, name: 'uk_uh'
    end
  end

  def down
    run_migration_for_db(DbConnection::KitSaasSubenv) do
      remove_column :workflows, :unique_hash
      remove_index :workflow_steps, name: 'uk_uh'
    end
  end
end

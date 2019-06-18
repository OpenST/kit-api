class AddUniqueHashInWorkflows < DbMigrationConnection
  def up
    run_migration_for_db(DbConnection::KitSaasSubenv) do
      add_column :workflows, :unique_hash, :string, :null => true, :after => :client_id
      add_index :workflows, [:unique_hash], unique: true, name: 'uk_uh'
    end
  end

  def down
    run_migration_for_db(DbConnection::KitSaasSubenv) do
      remove_index :workflows, name: 'uk_uh'
      remove_column :workflows, :unique_hash
    end
  end
end

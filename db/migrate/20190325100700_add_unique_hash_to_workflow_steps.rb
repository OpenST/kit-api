class AddUniqueHashToWorkflowSteps < DbMigrationConnection
  def up
    run_migration_for_db(DbConnection::KitSaasSubenv) do
      add_column :workflow_steps, :unique_hash, :string, unique: true, null: true
      add_index :workflow_steps, :unique_hash, name: 'uk_uh', unique: true

      WorkflowStep.select('id, workflow_id, kind as raw_kind, status').all.each do |row|
        if !row[:status].blank?
          row[:unique_hash] = row[:workflow_id].to_s + ":" + row[:raw_kind].to_s
          row.save!
        end
      end

      remove_index :workflow_steps, name: 'uk_uh'
      add_index :workflow_steps, :unique_hash, name: 'uk_uh', unique: false
    end
  end

  def down
    run_migration_for_db(DbConnection::KitSaasSubenv) do
      remove_index :workflow_steps, name: 'uk_uh'
      remove_column :workflow_steps, :unique_hash
    end
  end
end

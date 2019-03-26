class AddUniqueHashToWorkflowSteps < DbMigrationConnection
  def up
    run_migration_for_db(DbConnection::KitSaasSubenv) do
      add_column :workflow_steps, :unique_hash, :string, null: true, after: :response_data
      add_index :workflow_steps, :unique_hash, name: 'uk_uh', unique: true

      WorkflowStep.select('id, workflow_id, kind as raw_kind, status').all.each do |row|
        if !row[:status].blank?
          row[:unique_hash] = row[:workflow_id].to_s + ":" + row[:raw_kind].to_s
          row.save!
        end
      end

      remove_index :workflow_steps, name: 'cuk_wid_kind_status'
      add_index :workflow_steps, [:workflow_id, :kind, :status], unique: false, name: 'cuk_wid_kind_status'
    end
  end
end

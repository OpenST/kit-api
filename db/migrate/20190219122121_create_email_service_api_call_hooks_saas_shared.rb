class CreateEmailServiceApiCallHooksSaasShared < DbMigrationConnection

  def up

    run_migration_for_db(DbConnection::KitSaasBigSubenv) do

      create_table :email_service_api_call_hooks do |t|

        t.string :email, limit: 255, null: false

        t.column :event_type, :tinyint, null: false
        t.string :custom_description, limit: 255, null: true, default: nil

        t.integer :execution_timestamp, null: false
        t.decimal :lock_identifier, :precision => 22, :scale => 10, null: true
        t.integer :locked_at, null: true
        t.integer :status, null: false, default: 1
        t.integer :failed_count, null: false, default: 0

        t.text :params, default: nil
        t.text :success_response, null: true, default: nil
        t.text :failed_response, null: true, default: nil

        t.timestamps

      end

      add_index :email_service_api_call_hooks, [:execution_timestamp, :status], name: 'index_1'
      add_index :email_service_api_call_hooks, [:lock_identifier], name: 'index_2'

    end

  end

  def down
    run_migration_for_db(DbConnection::KitSaasBigSubenv) do
      drop_table :email_service_api_call_hooks
    end
  end


end

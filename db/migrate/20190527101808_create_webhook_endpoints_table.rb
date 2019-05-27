class CreateWebhookEndpointsTable < DbMigrationConnection
  def up

    run_migration_for_db(DbConnection::KitSaasSubenv) do

      create_table :webhook_endpoints do |t|
        t.column :uuid, :string, limit: 40, null: false
        t.column :client_id, :integer, null: false
        t.column :endpoint, :string, limit: 1000, null: false
        t.column :secret, :text, null: false #encrypted
        t.column :grace_secret, :text, null: true #encrypted
        t.integer :grace_expiry_at, null: false
        t.column :status, :tinyint, null: false, limit: 1
        t.timestamps
      end

      add_index :webhook_endpoints, [:client_id, :endpoint], name: 'uk_1', unique: true
    end

  end

  def down
    run_migration_for_db(DbConnection::KitSaasSubenv) do

      drop_table :webhook_endpoints if DbConnection::KitSaasSubenv.connection.table_exists? :webhook_endpoints

    end
  end

end

class CreateValidDomains < DbMigrationConnection
  def up
    run_migration_for_db(DbConnection::KitSaasSubenv) do
      create_table :valid_domains do |t|
        t.column :token_id, :int, null: false
        t.column :domain, :string, limit: 255, null: false
        t.timestamps
      end

      add_index :valid_domains, [:token_id], name: 'idx_1'
    end
  end

  def down
    run_migration_for_db(DbConnection::KitSaasSubenv) do
      remove_index :valid_domains, name: 'idx_1'
      drop_table :valid_domains if DbConnection::KitSaasSubenv.connection.table_exists? :valid_domains
    end
  end
end

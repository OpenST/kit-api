class CreateTokenRules < DbMigrationConnection
  def up
    run_migration_for_db(DbConnection::KitSaasSubenv) do
      create_table :token_rules do |t|
        t.column :token_id, :integer, null: false
        t.column :rule_id, :integer, null: false
        t.column :address, :string, limit: 255, null: false
        t.column :status, :tinyint, limit: 1, null: false
        t.timestamps
      end
      add_index :token_rules, [:token_id, :rule_id], name: 'cuk_token_id_rule_id', unique: true
      execute ("ALTER TABLE token_rules AUTO_INCREMENT = 50000")
    end
  end
  
  def down
    run_migration_for_db(DbConnection::KitSaasSubenv) do
      drop_table :token_rules if DbConnection::KitSaasSubenv.connection.table_exists? :token_rules
    end
  end
end
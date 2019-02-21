class AddRuleTokenIdNameInTokenRules < DbMigrationConnection
  def up
    run_migration_for_db(DbConnection::KitSaasSubenv) do
      add_column :token_rules, :rule_token_id, :integer, after: :token_id, default: 0
      add_column :token_rules, :rule_name, :string, null: false, after: :rule_token_id
    end
  end

  def down
    run_migration_for_db(DbConnection::KitSaasSubenv) do
      remove_column :token_rules, :rule_name
      remove_column :token_rules, :rule_token_id
    end
  end
end

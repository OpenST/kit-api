class CreateTokenCompanyUser < DbMigrationConnection

  def up
    run_migration_for_db(DbConnection::KitSaasSubenv) do
      create_table :token_company_users do |t|
        t.column :token_id, :integer, default: 0
        t.column :user_uuid, :string, limit: 40, null: false
        t.timestamps
      end
      add_index :token_company_users, [:token_id, :user_uuid], name: 'uk_1', unique: true
    end
  end

  def down
    run_migration_for_db(DbConnection::KitSaasSubenv) do
      drop_table :token_company_users if DbConnection::KitSaasSubenv.connection.table_exists? :token_company_users
    end
  end

end

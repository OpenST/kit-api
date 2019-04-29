class RemoveDefaultDecimalsFromTokens < DbMigrationConnection
  def up
    run_migration_for_db(DbConnection::KitSaasSubenv) do
      change_column :tokens, :decimal, :integer, null: true, :default => nil
    end
  end

  def down
    run_migration_for_db(DbConnection::KitSaasSubenv) do
      change_column :tokens, :decimal, :integer, :default => 18
    end
  end
end

class AddDefaultOnTokenProperties < DbMigrationConnection
  def up
    run_migration_for_db(DbConnection::KitSaasSubenv) do

      Token.where(properties: nil).each do |token|
        token[:properties] = 0
        token.save!
      end

      change_column :tokens, :properties, :tinyint, null: false, default: 0
    end
  end

  def down
    run_migration_for_db(DbConnection::KitSaasSubenv) do
      change_column :tokens, :properties, :tinyint, null: true
    end
  end
end

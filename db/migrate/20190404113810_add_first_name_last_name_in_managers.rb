class AddFirstNameLastNameInManagers < DbMigrationConnection
  def up
    run_migration_for_db(DbConnection::KitClient) do
      add_column :managers, :first_name, :string, :null => true, :after => :id
      add_column :managers, :last_name, :string, :null => true, :after => :first_name
    end
  end

  def down
    run_migration_for_db(DbConnection::KitClient) do
      remove_column :managers, :last_name
      remove_column :managers, :first_name
    end
  end
end

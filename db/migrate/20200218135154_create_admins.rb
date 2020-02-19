class CreateAdmins < DbMigrationConnection
  def up
    run_migration_for_db(DbConnection::KitSaas) do
      create_table :admins do |t|
        t.column :name, :string, limit: 255, null: false
        t.column :email, :string, limit: 255, null: false
        t.column :slack_id, :string, limit: 255, null: true
        t.column :status, :tinyint, limit: 1, null: false
        t.timestamps
      end

      add_index :admins, [:slack_id], name: 'idx_1'
      add_index :admins, [:email], name: 'idx_2'
    end
  end

  def down
    run_migration_for_db(DbConnection::KitSaas) do
      drop_table :admins if DbConnection::KitSaas.connection.table_exists? :admins
    end
  end
end

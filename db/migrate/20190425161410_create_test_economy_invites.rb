class CreateTestEconomyInvites < DbMigrationConnection

  def up
    run_migration_for_db(DbConnection::KitBigSubenv) do
      create_table :test_economy_invites do |t|
        t.column :token_id, :integer, null: false
        t.column :email, :string, null: false
        t.integer :last_invitation_timestamp, null: false
        t.timestamps
      end

      add_index :test_economy_invites, [:token_id, :email], name: 'uk_1', unique: true
      add_index :test_economy_invites, [:token_id, :last_invitation_timestamp], name: 'idx_1'
    end
  end

  def down
    run_migration_for_db(DbConnection::KitBigSubenv) do
      drop_table :test_economy_invites if DbConnection::KitBigSubenv.connection.table_exists? :test_economy_invites
    end
  end
  
end

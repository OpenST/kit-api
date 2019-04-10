class CreateStakeCurrencies < DbMigrationConnection
  def up

    run_migration_for_db(DbConnection::KitSaasSubenv) do

      create_table :stake_currencies do |t|
        t.column :name, :string, limit: 255, null: false
        t.column :symbol, :string, limit: 255, null: false
        t.column :decimal, :integer, null: false
        t.column :contract_address, :string, limit: 255, null: false
        t.timestamps
      end

      add_index :stake_currencies, [:contract_address], name: 'sc_ca_1', unique: true

    end

  end

  def down
    run_migration_for_db(DbConnection::KitSaasSubenv) do

      drop_table :stake_currencies if DbConnection::KitSaasSubenv.connection.table_exists? :stake_currencies

    end
  end

end

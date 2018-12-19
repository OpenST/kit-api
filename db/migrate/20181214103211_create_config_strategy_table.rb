class CreateConfigStrategyTable < DbMigrationConnection

  def up

    default_inactive_value = 2
    run_migration_for_db(EstablishConfigDbConnection) do

      create_table :config_strategies do |t|
        t.column :kind, :tinyint, limit: 1, null: false
        t.column :chain_id, :integer, null: false
        t.column :group_id, :integer, null: false
        t.column :status, :tinyint, limit: 1, null: false
        t.column :unencrypted_params, :text, null: false
        t.column :encrypted_params, :text, null: true
        t.column :encryption_salt_id, :integer, limit: 8, null: true
        t.timestamps
      end

      add_index :config_strategies, [:kind, :chain_id, :group_id], unique: true, name: 'uk_kind_chain_id_group_id_uniq'
    end

  end

  def down

    run_migration_for_db(EstablishConfigDbConnection) do

      drop_table :config_strategies

    end

  end

end

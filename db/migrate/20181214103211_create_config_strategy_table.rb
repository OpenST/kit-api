class CreateConfigStrategyTable < DbMigrationConnection

  def up

    default_inactive_value = 2
    run_migration_for_db(EstablishSaasConfigDbConnection) do

      create_table :config_strategies do |t|
        t.column :chain_id, :string, limit: 255, null: true
        t.column :kind, :tinyint, limit: 1, null: false
        t.column :encrypted_params, :text, null: true #encrypted
        t.column :unencrypted_params, :text
        t.column :hashed_params, :text, null: false
        t.column :status, :integer, null: false, default: default_inactive_value
        t.column :managed_address_salts_id, :integer,limit: 8, null: false
        t.timestamps
      end

      add_index :config_strategies, [:chain_id, :kind], unique: true, name: 'uk_chain_id_kind_uniq'
    end

  end

  def down

    run_migration_for_db(EstablishSaasConfigDbConnection) do

      drop_table :config_strategies

    end

  end

end

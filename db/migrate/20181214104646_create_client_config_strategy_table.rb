class CreateClientConfigStrategyTable < DbMigrationConnection

  def up

    run_migration_for_db(EstablishSaasConfigDbConnection) do
      create_table :client_config_strategies do |t|
        t.column :client_id, :integer, null: false
        t.column :config_strategy_id, :integer, null: false
        t.column :auxilary_data, :text, null: true
        t.timestamps
      end

      add_index :client_config_strategies, [:client_id ,:config_strategy_id], name: 'client_config_strategy_id', unique: true

    end

  end


  def down

    run_migration_for_db(EstablishSaasConfigDbConnection) do

      drop_table :client_config_strategies

    end

  end

end

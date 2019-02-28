class CreateTransactionMeta < DbMigrationConnection
  def up
    run_migration_for_db(DbConnection::SaasBigSubenv) do

      create_table :transaction_meta do |t|
        t.column :associated_aux_chain_id, :integer, null: false
        t.column :transaction_hash, :string, null: true
        t.column :transaction_uuid, :string, null: false
        t.column :token_id, :integer, null: false
        t.column :status, :tinyint, limit: 1, null: false
        t.column :kind, :tinyint, limit: 1, null: false
        t.column :retry_count, :integer, default: 0
        t.column :next_action_at, :integer, null: true
        t.column :lock_id, :decimal, :precision => 22, :scale => 5, null: true
        t.column :debug_params, :text
        t.column :sender_address, :string, null: true
        t.column :sender_nonce, :integer, null: true
        t.column :session_address, :string, null: true
        t.column :session_nonce, :integer, null: true
        t.timestamps
      end

      add_index :transaction_meta, [:transaction_uuid], name: 'uniq_transaction_uuid', unique: true
      add_index :transaction_meta, [:transaction_hash, :associated_aux_chain_id], name: 'uniq_transaction_hash_chain_id', unique: true
      add_index :transaction_meta, [:lock_id], name: 'index_lock_id'
      add_index :transaction_meta, [:session_address, :session_nonce], name: 'index_session_address_session_nonce'

      query = "CREATE TABLE transaction_meta_archive like transaction_meta;"
      DbConnection::SaasBigSubenv.connection.execute(query)

    end
  end

  def down
    run_migration_for_db(DbConnection::SaasBigSubenv) do

      drop_table :transaction_meta
      drop_table :transaction_meta_archive

    end
  end
end

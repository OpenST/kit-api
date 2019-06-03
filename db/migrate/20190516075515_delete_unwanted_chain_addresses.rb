class DeleteUnwantedChainAddresses < DbMigrationConnection
  def up
    run_migration_for_db(DbConnection::KitSaasSubenv) do
      ChainAddresses.where(kind: [3,4,5,46]).destroy_all
    end
  end

  def down
    # do nothing
  end
end

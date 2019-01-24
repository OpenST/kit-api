class AddOstToWhitelist < DbMigrationConnection

  def up
    run_migration_for_db(DbConnection::KitClient) do
      ClientWhitelisting.create(kind: GlobalConstant::ClientWhitelisting.domain_kind, identifier: 'ost.com')
    end
  end

  def down

  end

end

class AddOstToWhitelist < DbMigrationConnection

  def up
    ClientWhitelisting.create(kind: GlobalConstant::ClientWhitelisting.domain_kind, identifier: 'ost.com')
  end

  def down

  end

end

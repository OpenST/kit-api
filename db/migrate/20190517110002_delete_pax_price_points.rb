class DeletePaxPricePoints < DbMigrationConnection
  def up
    run_migration_for_db(DbConnection::KitSaasSubenv) do
      CurrencyConversionRate.where(stake_currency_id: 2).destroy_all
    end
  end

  def down
    # Do nothing
  end
end

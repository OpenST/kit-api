class ClientWhitelisting < EstablishCompanyClientDbConnection

  enum kind: {
      GlobalConstant::ClientWhitelisting.domain_kind => 1,
      GlobalConstant::ClientWhitelisting.email_kind => 2
  }

end

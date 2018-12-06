class ManagerWhitelisting < EstablishCompanyManagerDbConnection

  enum kind: {
      GlobalConstant::ManagerWhitelisting.reset_password_kind => 1,
      GlobalConstant::ManagerWhitelisting.double_optin_kind => 2,
      GlobalConstant::ManagerWhitelisting.manager_invite_kind => 3
  }

end

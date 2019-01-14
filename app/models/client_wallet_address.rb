class ClientWalletAddress < DbConnection::KitSaas

  enum sub_environment: {
    GlobalConstant::Environment.main_sub_environment => 1,
    GlobalConstant::Environment.sandbox_sub_environment => 2
  }

  enum status: {
    GlobalConstant::WalletAddressStatus.active_status => 1,
    GlobalConstant::WalletAddressStatus.inactive_status => 2
  }

end
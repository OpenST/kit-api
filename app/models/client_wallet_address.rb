class ClientWalletAddress < DbConnection::KitSaas

  enum sub_environment: {
    GlobalConstant::Environment.mainnet_url_prefix => 1,
    GlobalConstant::Environment.testnet_url_prefix => 2
  }

  enum status: {
    GlobalConstant::WalletAddressStatus.active_status => 1,
    GlobalConstant::WalletAddressStatus.inactive_status => 2
  }

end
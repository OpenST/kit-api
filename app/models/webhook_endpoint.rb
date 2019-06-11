class WebhookEndpoint < DbConnection::KitSaasSubenv

  enum status: {
    GlobalConstant::WebhookEndpoints.active => 1,
    GlobalConstant::WebhookEndpoints.inactive => 2,
    GlobalConstant::WebhookEndpoints.deleteStatus => 3
  }

end
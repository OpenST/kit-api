class WebhookEndpoints < DbConnection::KitSaasSubenv

  enum status: {
    GlobalConstant::WebhookEndpoints.active => 1,
    GlobalConstant::WebhookEndpoints.inactive => 2
  }

end
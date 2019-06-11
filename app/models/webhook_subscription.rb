class WebhookSubscription < DbConnection::KitSaasSubenv

  enum status: {
    GlobalConstant::WebhookSubscriptions.active => 1,
    GlobalConstant::WebhookSubscriptions.inactive => 2
  }
  
end
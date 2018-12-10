Sidekiq.configure_server do |config|
  config.redis = {url: GlobalConstant::Redis.url, namespace: GlobalConstant::Redis.sidekiq_namespace}
  # config.poll_interval = 1
  config.average_scheduled_poll_interval = 1
end

Sidekiq.configure_client do |config|
  config.redis = {url: GlobalConstant::Redis.url, namespace: GlobalConstant::Redis.sidekiq_namespace}
end

Sidekiq.default_worker_options = {retry: 0, backtrace: true}

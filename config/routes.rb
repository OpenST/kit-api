Rails.application.routes.draw do

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  scope '', controller: 'application', :format => false do
    get '/health-checker' => :health_checker
  end

  scope 'api/sign-up', controller: 'access/login', :format => false do
    match '' => :sign_up_get, via: :GET
    match '' => :sign_up_post, via: :POST, constraints: lambda { |request| request.xhr? }
  end

  scope 'api/verify-email', controller: 'access/verify_email', :format => false do
    match '' => :verify_email, via: :GET
    match 'request-link' => :send_verify_email_link, via: :POST, constraints: lambda { |request| request.xhr? }
  end

  scope 'api/mfa', controller: 'access/mfa', :format => false do
    match '' => :mfa, via: :GET, as: :mfa
    match '' => :multi_factor_auth, via: :POST, as: :multi_factor_auth, constraints: lambda { |request| request.xhr? }
  end

  scope 'api/setting/company-information', controller: 'setting/company_information', :format => false do
    match '' => :get, via: :GET
    match '' => :update, via: :POST, constraints: lambda { |request| request.xhr? }
  end

  scope 'api/login', controller: 'access/login', :format => false do
    match '' => :password_auth, via: :POST, constraints: lambda { |request| request.xhr? }
  end

  scope 'api/reset-password', controller: 'access/login', :format => false do
    match '' => :reset_password, via: :POST, constraints: lambda { |request| request.xhr? }
    match 'request-link' => :send_reset_password_link, via: :POST, constraints: lambda { |request| request.xhr? }
  end

  scope 'api/logout', controller: 'access/logout', :format => false do
    match '' => :logout, via: :GET
  end

  scope 'api/setting/team', controller: 'setting/team', :format => false do
    match '' => :get, via: :GET
    match 'list' => :list_admins, via: :GET, constraints: lambda { |request| request.xhr? }
    match 'reset-mfa' => :reset_mfa, via: :POST, constraints: lambda { |request| request.xhr? }
    match 'invite-admin' => :invite_admin, via: :POST, constraints: lambda { |request| request.xhr? }
    match 'delete-admin' => :delete_admin, via: :POST, constraints: lambda { |request| request.xhr? }
    match 'resend-admin-invite' => :resend_admin_invite, via: :POST, constraints: lambda { |request| request.xhr? }
    match 'update-super-admin-role' => :update_super_admin_role, via: :POST, constraints: lambda { |request| request.xhr? }
  end

  scope "#{GlobalConstant::Environment.url_prefix}/api/developer", controller: 'developer', :format => false do
    match '' => :developer_get, via: :GET
    match 'api-keys' => :api_keys_get, via: :GET, constraints: lambda { |request| request.xhr? }
    match 'api-keys' => :api_keys_rotate, via: :POST, constraints: lambda { |request| request.xhr? }
    match 'api-keys/delete' => :api_keys_deactivate, via: :POST, constraints: lambda { |request| request.xhr? }

    match 'webhook-secrets' => :webhook_secret_get, via: :GET, constraints: lambda { |request| request.xhr? }
    match 'webhook-secrets' => :webhook_secret_rotate, via: :POST, constraints: lambda { |request| request.xhr? }
    match 'delete-webhook-secrets' => :delete_webhook_secret, via: :POST, constraints: lambda { |request| request.xhr? }
  end

  scope "#{GlobalConstant::Environment.url_prefix}/api/token/dashboard", controller: 'dashboard', :format => false do
    match '' => :get, via: :GET
  end

  scope "#{GlobalConstant::Environment.url_prefix}/api/token", controller: 'token/setup', :format => false do
    match '' => :token_details_get, via: :GET
    match '' => :token_details_post, via: :POST, constraints: lambda { |request| request.xhr? }
    match 'deploy' => :deploy_get, via: :GET
    match 'deploy' => :deploy_post, via: :POST, constraints: lambda { |request| request.xhr? }
    match 'balance' => :balance_get, via: :GET, constraints: lambda { |request| request.xhr? }
    match 'request-whitelist' => :request_whitelist, via: :POST, constraints: lambda { |request| request.xhr? }
  end

  scope "#{GlobalConstant::Environment.url_prefix}/api/token/addresses", controller: 'token/addresses', :format => false do
    match '' => :token_addresses_post, via: :POST, constraints: lambda { |request| request.xhr? }
    match 'create-managed-address' => :create_ost_managed_address, via: :POST, constraints: lambda { |request| request.xhr? }
  end

  scope "#{GlobalConstant::Environment.url_prefix}/api/token/mint", controller: 'token/mint', :format => false do
    match '' => :mint_get, via: :GET
    match '' => :mint_post, via: :POST, constraints: lambda { |request| request.xhr? }
    match 'progress' => :mint_progress, via: :GET
  end

  scope "#{GlobalConstant::Environment.url_prefix}/api/grant", controller: 'grant', :format => false do
    match '' => :get, via: :GET, constraints: lambda { |request| request.xhr? }
  end

  scope "#{GlobalConstant::Environment.url_prefix}/api/token", controller: 'token/pre_mint', :format => false do
    match 'pre-mint' => :get_pre_mint_details, via: :GET, constraints: lambda { |request| request.xhr? }
  end

  scope "#{GlobalConstant::Environment.url_prefix}/api/workflow/:workflow_id", controller: 'workflow', :format => false do
    match '' => :workflow_status, via: :GET, constraints: lambda { |request| request.xhr? }
  end

  scope "#{GlobalConstant::Environment.url_prefix}/api/test-economy", controller: 'test_economy', :format => false do
    match '' => :get, via: :GET
    match 'invite' => :invite, via: :POST, constraints: lambda { |request| request.xhr? }
    match '' => :activate, via: :POST, constraints: lambda { |request| request.xhr? ||
        request.params[:auth_token] == GlobalConstant::Base.activate_test_economy_auth_token }
  end

  # Handle any other routes
  match '*permalink', to: 'application#not_found', via: :all

end

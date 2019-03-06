Rails.application.routes.draw do

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  scope '', controller: 'application' do
    get '/health-checker' => :health_checker
  end

  scope 'api/manager', controller: 'manager/login' do
    match 'sign-up' => :sign_up_get, via: :GET
    match 'sign-up' => :sign_up_post, via: :POST
    match 'mfa' => :mfa, via: :GET, as: :mfa
    match 'mfa' => :multi_factor_auth, via: :POST, as: :multi_factor_auth
    match 'login' => :password_auth, via: :POST
    match 'logout' => :logout, via: :GET
    match 'reset-password' => :reset_password, via: :POST
    match 'send-reset-password-link' => :send_reset_password_link, via: :POST
    match 'verify-email' => :verify_email, via: :GET
    match 'send-verify-email-link' => :send_verify_email_link, via: :POST
    match '' => :get_details, via: :GET
  end

  scope 'api/manager', controller: 'manager/team' do
    match 'team' => :get, via: :GET
    match 'list-admins' => :list_admins, via: :GET
  end

  scope 'api/manager/super_admin', controller: 'manager/team' do
    match 'reset-mfa' => :reset_mfa, via: :POST
    match 'invite-admin' => :invite_admin, via: :POST
    match 'delete-admin' => :delete_admin, via: :POST
    match 'resend-admin-invite' => :resend_admin_invite, via: :POST
    match 'update-super-admin-role' => :update_super_admin_role, via: :POST
  end

  scope "#{GlobalConstant::Environment.url_prefix}/api/developer", controller: 'developer' do
    match '' => :developer_get, via: :GET
    match 'api-keys' => :api_keys_get, via: :GET
    match 'api-keys' => :api_keys_rotate, via: :POST
    match 'api-keys/delete' => :api_keys_deactivate, via: :POST
  end

  scope "#{GlobalConstant::Environment.url_prefix}/api/token", controller: 'token/setup' do
    match '' => :token_details_get, via: :GET
    match '' => :token_details_post, via: :POST
    match 'deploy' => :deploy_get, via: :GET
    match 'deploy' => :deploy_post, via: :POST
    match 'mint-progress' => :mint_progress, via: :GET
    match 'request-whitelist' => :request_whitelist, via: :POST
  end

  scope "#{GlobalConstant::Environment.url_prefix}/api/token/mint", controller: 'token/mint' do
    match '' => :mint_get, via: :GET
    match '' => :mint_post, via: :POST
    match 'grant' => :grant_get, via: :GET
  end

  scope "#{GlobalConstant::Environment.url_prefix}/api/token/addresses", controller: 'token/addresses' do
    # TODO: Clean up later.
    # match '' => :token_addresses_get, via: :GET
    match '' => :token_addresses_post, via: :POST
    match 'is-available' => :token_addresses_is_available, via: :GET
    match 'sign-messages' => :token_addresses_sign_messages, via: :GET
  end

  scope "#{GlobalConstant::Environment.url_prefix}/api/contracts", controller: 'contracts/gateway_composer' do
    match 'gateway-composer' => :get_details, via: :GET
  end

  scope "#{GlobalConstant::Environment.url_prefix}/api/workflow/:workflow_id", controller: 'workflow' do
    match '' => :workflow_status, via: :GET
  end

  # Handle any other routes
  match '*permalink', to: 'application#not_found', via: :all

end

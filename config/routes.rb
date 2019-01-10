Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  scope 'admin/api', controller: 'admin/whitelist' do
    match 'whitelist' => :whitelist_domain_or_email, via: :GET
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
    match 'list-admins' => :list_admins, via: :GET
    match '' => :get_details, via: :GET
  end

  scope 'api/manager/super_admin', controller: 'manager/super_admin' do
    match 'reset-mfa' => :reset_mfa, via: :POST
    match 'invite-admin' => :invite_admin, via: :POST
    match 'delete-admin' => :delete_admin, via: :POST
    match 'resend-admin-invite' => :resend_admin_invite, via: :POST
    match 'update-super-admin-role' => :update_super_admin_role, via: :POST
  end

  scope "#{GlobalConstant::Environment.url_prefix}/api/token", controller: 'token/setup' do
    match '' => :token_details_get, via: :GET
    match '' => :token_details_post, via: :POST
  end

  scope "#{GlobalConstant::Environment.url_prefix}/api/token/addresses", controller: 'token/addresses' do
    match '' => :token_addresses_post, via: :POST
    match 'is-available' => :token_addresses_is_available, via: :GET
    match 'sign-messages' => :token_addresses_sign_messages, via: :GET
  end

  # Handle any other routes
  match '*permalink', to: 'application#not_found', via: :all

end

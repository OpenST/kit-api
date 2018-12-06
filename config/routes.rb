Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  
  scope 'api/admin', controller: 'admin/whitelist' do
    match 'whitelist/domain' => :whitelist_domain, via: :GET
    match 'whitelist/email' => :whitelist_email, via: :GET
  end

  scope 'api/client', controller: 'client/login' do
    match 'verify-cookie' => :verify_cookie, via: :GET
    match 'sign-up' => :sign_up, via: :POST
    match 'login' => :login, via: :POST
    match 'logout' => :logout, via: :GET
    match 'reset-password' => :reset_password, via: :POST
    match 'send-reset-password-link' => :send_reset_password_link, via: :POST
    match 'verify-email' => :verify_email, via: :GET
    match 'send-verify-email-link' => :send_verify_email_link, via: :POST
  end

  scope 'api/client', controller: 'client/setup' do
    match 'validate-eth-address' => :validate_eth_address, via: :GET
    match 'fetch-api-credentials' => :fetch_api_credentials, via: :GET
    match 'get-ost' => :get_test_ost, via: :POST
    match 'get-eth' => :get_test_eth, via: :POST
    match 'setup-eth-address' => :setup_eth_address, via: :POST
  end

  scope 'api/economy/users', controller: 'economy/user' do
    match 'create' => :create_user, via: :POST
    match 'edit' => :edit_user, via: :POST
    match 'list' => :list_users, via: :GET
    match 'airdrop' => :airdrop_users, via: :POST
    match 'fetch-balances' => :fetch_balances, via: :GET
  end

  scope 'api/economy/token', controller: 'economy/token' do
    match 'get-step-one-details' => :get_step_one_details, via: :GET
    match 'get-step-two-details' => :get_step_two_details, via: :GET
    match 'get-step-three-details' => :get_step_three_details, via: :GET
    match 'get-dashboard-details' => :get_dashboard_details, via: :GET
    match 'get-supply-details' => :get_supply_details, via: :GET
    match 'get-critical-chain-interaction-status' => :get_critical_chain_interaction_status, via: :GET
    match 'plan' => :plan_token, via: :POST
    match 'stake-and-mint' => :stake_and_mint, via: :POST
    match 'graph/transaction-types' => :transaction_type_graph, via: :GET
    match 'graph/number-of-transactions' => :number_of_transactions_graph, via: :GET
    match 'graph/top-users' => :top_users_graph, via: :GET
  end

  scope 'api/economy/action', controller: 'economy/transaction_kind' do
    match 'create' => :create, via: :POST
    match 'edit' => :edit, via: :POST
    match 'bulk-create-edit' => :bulk_create_edit, via: :POST
    match 'list' => :list, via: :GET
  end

  scope 'api/economy/transaction', controller: 'economy/transaction' do
    match 'execute' => :simulate, via: :POST
    match 'history' => :fetch_history, via: :GET
    match 'fetch-detail' => :fetch_detail, via: :GET
    match 'fetch-simulator-details' => :fetch_simulator_details, via: :GET
  end

  scope 'api/economy/developer-api-console', controller: 'economy/developer_api_console' do
    match '' => :fetch, via: :GET
  end

  # Handle any other routes
  match '*permalink', to: 'application#not_found', via: :all

end

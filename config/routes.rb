Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  scope 'api/admin', controller: 'admin/whitelist' do
    match 'whitelist' => :whitelist_domain_or_email, via: :GET
  end

  # Handle any other routes
  match '*permalink', to: 'application#not_found', via: :all

end

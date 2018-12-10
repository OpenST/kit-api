Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  # Handle any other routes
  match '*permalink', to: 'application#not_found', via: :all

end

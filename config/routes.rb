Rails.application.routes.draw do
  resources :hooks, only: %i(new create)
end

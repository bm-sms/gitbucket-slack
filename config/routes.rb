Rails.application.routes.draw do
  root to: 'welcome#index'

  resources :hooks, only: %i(new create show) do
    member do
      post :update
    end
  end
end

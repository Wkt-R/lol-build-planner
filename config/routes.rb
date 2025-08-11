Rails.application.routes.draw do
  root "matchups#new"
  resources :matchups
end
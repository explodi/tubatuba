Rails.application.routes.draw do
  get "/admin" => "events#admin"
  get "/login" => "sessions#new"
  post "/sessions/create" => "sessions#create"
  root :to => "events#index"

end

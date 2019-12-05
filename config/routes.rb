Rails.application.routes.draw do
  get "/admin" => "admin#dashboard"
  get "/admin/events" => "admin#dashboard"

  get "/login" => "sessions#new"
  post "/sessions/create" => "sessions#create"
  root :to => "events#index"

end

Rails.application.routes.draw do
  get "/admin/events/index" => "admin#events_index"
  get "/admin/events/new" => "admin#events_new"
  post "/admin/events/create" => "admin#events_create"
  get "/admin/events/edit/:id" => "admin#events_edit"
  get "/admin/events/destroy/:id" => "admin#events_destroy"
  get "/admin/events/recover/:id" => "admin#events_recover"

  post "/admin/events/update" => "admin#events_update"

  get "/admin" => "admin#dashboard"
  get "/login" => "sessions#new"
  post "/sessions/create" => "sessions#create"
  root :to => "events#index"

end

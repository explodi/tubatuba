Rails.application.routes.draw do
  get "/admin/events/index" => "admin#events_index"
  get "/admin/events/new" => "admin#events_new"
  post "/admin/events/create" => "admin#events_create"
  get "/admin/events/flyers/:id" => "admin#events_flyers"
  get "/admin/events/edit/:id" => "admin#events_edit"
  get "/admin/events/destroy/:id" => "admin#events_destroy"
  post "/admin/events/videos/create" => "admin#events_videos_create"
  get "/admin/events/recover/:id" => "admin#events_recover"
  get "/admin/acts/index/:id" => "admin#acts_index"
  post "/admin/events/update" => "admin#events_update"
  post "/admin/acts/create" => "admin#acts_create"
  post "/admin/acts/destroy" => "admin#acts_destroy"
  get "/evento/:id" => "events#show"
  get "/admin" => "admin#dashboard"
  get "/login" => "sessions#new"
  post "/sessions/create" => "sessions#create"
  root :to => "events#index"

end

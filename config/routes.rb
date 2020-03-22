Rails.application.routes.draw do
  get "/admin/events/index" => "admin#events_index"
  get "/admin/songs/index" => "admin#songs_index"
  post "/admin/songs/create" => "admin#songs_create"
  get "/admin/songs/:id/destroy" => "admin#songs_destroy"
  get "/admin/songs/new" => "admin#songs_new"
  get "/admin/songs/:id/upvote" => "admin#songs_upvote"
  get "/admin/songs/:id/downvote" => "admin#songs_downvote"
  get '/radio/current_song' => "radio#current_song"
  get "/admin/events/new" => "admin#events_new"
  post "/admin/events/create" => "admin#events_create"
  get "/admin/events/flyers/:id" => "admin#events_flyers"
  get "/admin/events/edit/:id" => "admin#events_edit"
  get "/admin/events/destroy/:id" => "admin#events_destroy"
  post "/admin/events/videos/create" => "admin#events_videos_create"
  get "/admin/events/recover/:id" => "admin#events_recover"
  get "/admin/acts/index/:id" => "admin#acts_index"
  get "/admin/video_formats/index" => "admin#video_formats_index"
  post "/admin/video_formats/create" => "admin#video_formats_create"
  get "/admin/video_formats/:id/destroy" => "admin#video_formats_destroy"
  get '/radio' => "radio#show"
  post "/admin/events/update" => "admin#events_update"
  post "/admin/acts/create" => "admin#acts_create"
  post "/admin/acts/destroy" => "admin#acts_destroy"
  get "/evento/:id/:format_id" => "events#show"
  get "/evento/:id" => "events#show"
  get "/admin" => "admin#dashboard"
  get "/login" => "sessions#new"
  post "/sessions/create" => "sessions#create"
  get "/admin/events/:id/videos/index" => "admin#events_videos_index"
  post "/admin/users/create" => "admin#users_create"
  get "/admin/users/new" => "admin#users_new"
  get "/admin/users/index" => "admin#users_index"
  get "/jpegs"=>"pages#jpegs"
  root :to => "events#index"
  match '*any', to: 'pages#not_found', via: [:get, :post]

end

Rails.application.routes.draw do
  get "/admin" => "events#admin"
  root :to => "events#index"

end

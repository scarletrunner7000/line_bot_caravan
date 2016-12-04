Rails.application.routes.draw do

  get 'webhook/callback'

  post '/callback' => 'webhook#callback', defaults: { format: :json }

end

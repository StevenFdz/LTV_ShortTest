Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html

  require 'resque/server'
  mount Resque::Server, at: '/admin/jobs'

 resources :short_url, only: [:index, :create, :show, :updated] 
    get "/" => "short_url#index"
    get '*title' => 'short_url#show'
    post '/' => 'short_url#create'
    put "/" => "short_url#updated"

end

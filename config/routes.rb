Project::Application.routes.draw do
  get "home/index"
  get "home/tutorial"

  namespace :admin do
    resources :users, :cards, :types, :factions, :players, :effects, :updates, :decks
    get "log_in" => "sessions#new"
    post "log_in" => "sessions#create"
    get "log_out" => "sessions#destroy"
    get "home" => "homes#index"
  end

  namespace :game do
    resources :servers
    get "join/:key" => "servers#join", :as => "join"
    get "board/:key" => "board#index", :as => "board"
    post "board/disconnect" => "board#disconnect", :as => "disconnect"
    post "board/ready" => "board#ready", :as => "ready"
    post "board/chat" => "board#chat", :as => "chat"
    post "turn/draw" => "turns#draw"
    post "turn/flip" => "turns#flip"
    post "turn/place" => "turns#place"
    post "turn/deploy" => "turns#deploy"
    post "turn/attack" => "turns#attack"
    post "turn/end_turn" => "turns#end_turn"
    post "turn/start_turn" => "turns#start_turn"
  end

  namespace :user do
    resources :decks
    get "log_in" => "sessions#new"
    post "log_in" => "sessions#create"
    get "log_out" => "sessions#destroy"
    get "register" => "users#new"
    post "register" => "users#create"
    get 'show/:id' => 'users#show', :as => "show"
    get 'edit/:id' => 'users#edit', :as => "edit"
    put "update/:id" => "users#update", :as => "update"
    get "delete/:id" => "users#destroy"
  end

  root :to => 'home#index'
end

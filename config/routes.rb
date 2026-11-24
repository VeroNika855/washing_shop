Rails.application.routes.draw do
  root "products#index"

  get "pages/:slug", to: "pages#show", as: :page
  get "info/:slug", to: "info#show", as: :info

  get  "gift-cards", to: "gift_cards#show", as: :gift_cards
  post "gift-cards", to: "gift_cards#create"

  resources :callback_requests, only: :create

  get    "register", to: "users#new"
  post   "register", to: "users#create"
  get    "login",    to: "sessions#new"
  post   "login",    to: "sessions#create"
  delete "logout",   to: "sessions#destroy"

  resource :account, only: :show, controller: "account"
  resources :products, only: %i[index show] do
    resources :reviews, only: :create
  end
  resources :reviews, only: :destroy
  resources :promotions, only: %i[index show]
  resources :orders, only: %i[new create show]

  get  "favorites", to: "favorites#index", as: :favorites
  post "favorites/:product_id", to: "favorites#toggle", as: :toggle_favorite

  post "cart/quick/:product_id", to: "cart_quick#create", as: :quick_cart_add

  resource :cart, only: :show, controller: "cart" do
    post "add/:product_id", action: :add, as: :add
    patch "update/:product_id", action: :update_item, as: :update
    delete "remove/:product_id", action: :remove, as: :remove
  end

  namespace :admin do
    root "dashboard#index"
    resources :products, except: %i[show destroy] do
      patch :toggle, on: :member
    end
    resources :promotions, only: :index
    patch  "promotions/:product_id", to: "promotions#save", as: :save_promotion
    delete "promotions/:product_id", to: "promotions#stop", as: :stop_promotion
    resources :callback_requests, only: %i[index destroy] do
      patch :toggle, on: :member
      resources :notes, only: %i[create destroy], controller: "callback_notes"
    end
    resources :orders, only: %i[index show update]
  end
end
Rails.application.routes.draw do
  scope path: ApplicationResource.endpoint_namespace, defaults: { format: :jsonapi } do
    resources :authors, only: %i[index show]
    resources :categories, only: :index
    resources :recipes, only: %i[index show]
    resources :recipe_likes, only: %i[create destroy]
    resources :featured_recipes, only: :create
    mount VandalUi::Engine, at: '/vandal'
  end
end

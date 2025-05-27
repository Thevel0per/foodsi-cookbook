Rails.application.routes.draw do
  scope path: ApplicationResource.endpoint_namespace, defaults: { format: :jsonapi } do
    resources :authors, only: %i[index show]
    resources :categories, only: :index
    resources :recipes, only: %i[index show]
    resources :recipe_likes, only: %i[create destroy]
    mount VandalUi::Engine, at: '/vandal'
  end
end

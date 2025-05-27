FactoryBot.define do
  factory :recipe_like do
    association :user
    association :recipe
  end
end

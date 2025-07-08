# frozen_string_literal: true

FactoryBot.define do
  factory :trading_account do
    name { Faker::Name.name }
    sequence(:login) { |n| "login#{n}" }
    phase { "student" }
    platform { "mt5" }
    user

    trait :student do
      phase { "student" }
    end

    trait :practitioner do
      phase { "practitioner" }
    end

    trait :senior do
      phase { "senior" }
    end

    trait :master do
      phase { "master" }
    end

    trait :mt5 do
      platform { "mt5" }
    end

    trait :matchtrader do
      platform { "matchtrader" }
    end

    trait :tradelocker do
      platform { "tradelocker" }
    end
  end
end

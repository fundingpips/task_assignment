# frozen_string_literal: true

FactoryBot.define do
  factory :ip_activity do
    ip_address_record { association(:ip_address) }
    activity_type { :trade }

    trait :for_trading_account do
      trading_account
      owning_user_id { trading_account.user_id }
    end

    trait :for_user do
      user
    end

    trait :login do
      activity_type { :login }
    end

    trait :kyc do
      activity_type { :kyc }
    end
  end
end

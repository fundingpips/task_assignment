# frozen_string_literal: true

FactoryBot.define do
  factory :ip_address do
    address { Faker::Internet.ip_v4_address }
    region { Faker::Address.state }
    country { Faker::Address.country_code }
    city { Faker::Address.city }
    lat { Faker::Address.latitude }
    lon { Faker::Address.longitude }
    is_vpn { false }
  end
end

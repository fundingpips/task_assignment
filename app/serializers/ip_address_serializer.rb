# frozen_string_literal: true

class IpAddressSerializer < ActiveModel::Serializer
  attributes :address, :region, :country, :city, :lat, :lon, :is_vpn
end

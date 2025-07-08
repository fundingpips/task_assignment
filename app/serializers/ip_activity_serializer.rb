# frozen_string_literal: true

class IpActivitySerializer < ActiveModel::Serializer
  attributes :id, :activity_type, :ip_address, :trading_account_login, :created_at, :updated_at

  belongs_to :user, serializer: UserSerializer
  belongs_to :trading_account, serializer: TradingAccountSerializer
  belongs_to :ip_address_record, key: :ip_address_details, serializer: IpAddressSerializer
end

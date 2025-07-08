# frozen_string_literal: true

class TradingAccountSerializer < ActiveModel::Serializer
  attributes :id, :name, :login, :phase, :platform

  belongs_to :user, serializer: UserSerializer
end

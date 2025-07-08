# frozen_string_literal: true

class User < ApplicationRecord
  has_many :trading_accounts, dependent: :destroy
  has_many :ip_activities, dependent: :destroy

  validates :email, presence: true, uniqueness: true
  validates :first_name, :last_name, presence: true
end

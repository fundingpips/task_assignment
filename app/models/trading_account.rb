# frozen_string_literal: true

class TradingAccount < ApplicationRecord
  belongs_to :user
  has_many :ip_activities, primary_key: :login, foreign_key: :trading_account_login, inverse_of: :trading_account, dependent: :destroy

  validates :name, :login, :platform, presence: true
  validates :login, uniqueness: true

  enum :phase, { student: 0, practitioner: 1, senior: 2, master: 3 }
  enum :platform, { mt5: 0, matchtrader: 1, tradelocker: 2 }
end

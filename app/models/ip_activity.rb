# frozen_string_literal: true

class IpActivity < ApplicationRecord
  enum :activity_type, { trade: 0, login: 1, kyc: 2 }

  validates :activity_type, :ip_address, presence: true
  validate :resource_presence

  belongs_to :ip_address_record,
             primary_key: :address,
             foreign_key: :ip_address,
             inverse_of:  :ip_activities,
             class_name:  "IpAddress"
  belongs_to :trading_account,
             primary_key: :login,
             foreign_key: :trading_account_login,
             inverse_of:  :ip_activities,
             optional:    true
  belongs_to :user, optional: true
  belongs_to :owning_user, class_name: "User", optional: true

  default_scope { order(created_at: :desc) }

  scope :for_user, lambda { |user|
    where(user:).includes(:user, :trading_account, :ip_address_record)
                .or(where(trading_account_login: user.trading_accounts.select(:login)))
  }
  scope :recent_n_per_activity_type, lambda { |limit|
    query = <<-SQL.squish
      SELECT activity_limited.id
      FROM (SELECT DISTINCT activity_type FROM ip_activities) activity_groups
      JOIN LATERAL (
        SELECT * FROM ip_activities activity_all
        WHERE activity_all.activity_type = activity_groups.activity_type
        ORDER BY activity_all.created_at DESC
        LIMIT :limit
      ) activity_limited ON true
    SQL

    where("ip_activities.id IN (#{ApplicationRecord.sanitize_sql([query, { limit: }])})")
  }

  def resource
    trading_account || user
  end

  private

  def resource_presence
    errors.add(:base, "Either user or trading_account must be present") unless user.present? || trading_account.present?
  end
end

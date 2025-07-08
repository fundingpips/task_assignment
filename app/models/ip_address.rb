# frozen_string_literal: true

class IpAddress < ApplicationRecord
  self.primary_key = :address

  has_many :ip_activities,
           primary_key: :address,
           foreign_key: :ip_address,
           inverse_of:  :ip_address_record,
           dependent:   :destroy

  validates :address, presence: true, uniqueness: true
end

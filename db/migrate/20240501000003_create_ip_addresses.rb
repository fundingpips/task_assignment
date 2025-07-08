# frozen_string_literal: true

class CreateIpAddresses < ActiveRecord::Migration[7.0]
  def change
    create_table :ip_addresses, id: false do |t|
      t.string :address, null: false, primary_key: true
      t.string :region
      t.string :country
      t.string :city
      t.float :lat
      t.float :lon
      t.boolean :is_vpn, default: false

      t.timestamps
    end

  end
end

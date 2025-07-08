# frozen_string_literal: true

class CreateIpActivities < ActiveRecord::Migration[7.0]
  def change
    create_table :ip_activities do |t|
      t.string :ip_address, null: false
      t.references :user, foreign_key: true
      t.integer :owning_user_id
      t.string :trading_account_login
      t.integer :activity_type, default: 0, null: false

      t.timestamps
    end

    add_foreign_key :ip_activities, :users, column: :owning_user_id
    add_foreign_key :ip_activities, :ip_addresses, column: :ip_address, primary_key: :address
    add_foreign_key :ip_activities, :trading_accounts, column: :trading_account_login, primary_key: :login
  end
end

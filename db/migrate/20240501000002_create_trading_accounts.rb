# frozen_string_literal: true

class CreateTradingAccounts < ActiveRecord::Migration[7.0]
  def change
    create_table :trading_accounts do |t|
      t.string :name, null: false
      t.string :login, null: false
      t.integer :phase, default: 0, null: false
      t.integer :platform, null: false
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end

    add_index :trading_accounts, :login, unique: true
  end
end

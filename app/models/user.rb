class User < ApplicationRecord
  has_secure_password
  has_many :sessions, dependent: :destroy
  has_one :meli_account, dependent: :destroy
  has_many :tax_accounts, dependent: :destroy
  has_many :products, dependent: :destroy
  has_many :meli_notifications, dependent: :destroy

  normalizes :email_address, with: ->(e) { e.strip.downcase }
end

class Order < ApplicationRecord
  belongs_to :user
  has_many :order_items, dependent: :destroy

  enum :source_channel,  { mercadolibre: 0 }
end

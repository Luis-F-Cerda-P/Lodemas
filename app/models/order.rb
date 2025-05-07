class Order < ApplicationRecord
  belongs_to :user

  enum :source_channel,  { mercadolibre: 0 }
end

class MeliAccount < ApplicationRecord
  belongs_to :user
  has_one :meli_auth_token, dependent: :destroy

  validates :mercadolibre_identifier, uniqueness: true, presence: true
end

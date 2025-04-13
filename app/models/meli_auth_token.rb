class MeliAuthToken < ApplicationRecord
  encrypts :access_token
  encrypts :refresh_token

  belongs_to :meli_account
end

class TaxAccount < ApplicationRecord
  belongs_to :user

  encrypts :password
end

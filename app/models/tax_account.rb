class TaxAccount < ApplicationRecord
  belongs_to :user

  has_one :jwt_token_set
  has_one :aws_credential_set

  encrypts :password
end

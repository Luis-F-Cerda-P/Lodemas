class AwsCredentialSet < ApplicationRecord
  belongs_to :tax_account

  encrypts :access_key_id
  encrypts :secret_access_key
  encrypts :session_token

  def expired?
    Time.current > expires_at
  end
end

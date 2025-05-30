class JwtTokenSet < ApplicationRecord
  belongs_to :tax_account

  encrypts :access_token
  encrypts :refresh_token
  encrypts :aws_token
  encrypts :identity_id

  def access_token_expired?
    Time.current > access_token_expires_at
  end

  def refresh_token_expired?
    Time.current > refresh_token_expires_at
  end

  def aws_token_expired?
    Time.current > aws_token_expires_at
  end
end
class JwtTokenSet < ApplicationRecord
  belongs_to :tax_account
end

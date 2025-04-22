class MeliAuthTokenRenewalJob < ApplicationJob
  queue_as :default

  def perform(user)
    user.meli_account.meli_auth_token.refresh!

    MeliAuthTokenRenewalJob.set(wait: 5.hours).perform_later(user)
  end
end

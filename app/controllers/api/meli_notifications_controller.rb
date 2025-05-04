class Api::MeliNotificationsController < ApplicationController
  allow_unauthenticated_access
  skip_before_action :verify_authenticity_token

  def create
    head :ok
  end
end

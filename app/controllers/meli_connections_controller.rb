class MeliConnectionsController < ApplicationController
  def new
  end

  def authorize
    MeliAuthorizationService.new(
      code: params[:code],
      current_user: Current.user
    ).call

    MeliAuthTokenRenewalJob.set(wait: 5.hours).perform_later(Current.user)

    redirect_to root_path
  end

  def destroy
  end

  private
  def product_params
    params.expect(:code)
  end
end

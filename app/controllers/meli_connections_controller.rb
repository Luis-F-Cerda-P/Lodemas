class MeliConnectionsController < ApplicationController
  def new
  end

  def authorize
    result = MeliAuthorizationService.new(
      code: params[:code],
      current_user: Current.user
    ).call

    if result.success
      redirect_to root_path, notice: "¡Conexión exitosa con MercadoLibre!"
    else
      redirect_to meli_connections_new_path, notice: result.error
    end
  end

  def destroy
  end

  private
  def product_params
    params.expect(product: [ :name, :description, :featured_image, :inventory_count ])
  end
end

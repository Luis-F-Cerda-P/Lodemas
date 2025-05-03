class ProductsController < ApplicationController
  include OwnedResource
  def index
  end

  def show
  end

  def new
    @product = Product.new
  end

  def create
    @product = Current.user.products.new(product_params)
    if @product.save
      redirect_to @product
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @product.update(product_params)
      redirect_to @product
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @product.destroy
    redirect_to products_path
  end

  private

    def product_params
      params.expect(product: [ :name, :description, :featured_image, :inventory_count ])
    end
end

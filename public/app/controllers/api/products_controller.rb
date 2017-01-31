class Api::ProductsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_product, only: [:show, :update, :destroy]

  # GET /products
  # GET /products.json
  def index
    @products = Product.by_user(current_user).all
    Rails.logger.debug "======s"
    Rails.logger.debug @products.to_json
    Rails.logger.debug "======e"
    render json: @products
  end

  # GET /products/1
  # GET /products/1.json
  def show
    render json: @product
  end

  # POST /products
  # POST /products.json
  def create
    @product = Product.new(product_params)

    current_user.products << @product

    if @product.save
      render json: @product, status: :created
    else
      render json: @product.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /products/1
  # PATCH/PUT /products/1.json
  def update
    @product = Product.find(params[:id])

    if @product.update(product_params)
      render json: @product
    else
      render json: @product.errors, status: :unprocessable_entity
    end
  end

  # DELETE /products/1
  # DELETE /products/1.json
  def destroy
    @product.destroy

    render json: @product
  end

  private

    def set_product
      @product = Product.by_user(current_user).find(params[:id])
    end

    def product_params
      params.require(:product).permit(:master_product_id,
                                      :title,
                                      :description,
                                      :price,
                                      :print_image_x_offset,
                                      :print_image_y_offset,
                                      :print_image_width,
                                      :print_image_height,
                                      :print_image,
                                      :product_image,
                                      :master_product_option_id,
                                      :master_product_size_id,
                                      :master_product_print_area_id,
                                      :product_color_ids,
                                      :product_size_ids)
    end
end

class Api::MasterProductsController < ApplicationController
  before_action :authenticate_user!
  before_action :check_admin, except: [:index, :show]
  before_action :set_master_product, only: [:show, :update, :destroy]

  # GET /master_products
  # GET /master_products.json
  def index
    @master_products = MasterProduct.all

    render json: @master_products
  end

  # GET /master_products/1
  # GET /master_products/1.json
  def show
    render json: @master_product
  end

  # POST /master_products
  # POST /master_products.json
  # def create
  #   @master_product = MasterProduct.new(master_product_params)

  #   if @master_product.save
  #     render json: @master_product, status: :created
  #   else
  #     render json: @master_product.errors, status: :unprocessable_entity
  #   end
  # end

  # PATCH/PUT /master_products/1
  # PATCH/PUT /master_products/1.json
  def update

    if @master_product.update(master_product_params)
      render json: @master_product
    else
      render json: @master_product.errors, status: :unprocessable_entity
    end
  end

  # DELETE /master_products/1
  # DELETE /master_products/1.json
  # def destroy
  #   @master_product.destroy

  #   render json: @master_product
  # end

  private

    def set_master_product
      @master_product = MasterProduct.find(params[:id])
    end

    def master_product_params
      params.require(:master_product).permit(:price)
    end
end

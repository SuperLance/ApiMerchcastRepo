class Api::ShopsController < ApplicationController
  before_action :authenticate_user!
  before_action :check_admin, except: [:create, :update, :show, :index]
  before_action :set_shop, only: [:show, :update, :destroy]

  # GET /shops
  # GET /shops.json
  def index
    @shops = Shop.by_user(current_user).all

    render json: @shops
  end

  # GET /shops/1
  # GET /shops/1.json
  def show
    render json: @shop
  end

  # POST /shops
  # POST /shops.json
  def create
    @shop = Shop.new(shop_params)
    current_user.shop = @shop

    if @shop.save
      render json: @shop, status: :created
    else
      render json: @shop.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /shops/1
  # PATCH/PUT /shops/1.json
  def update
    if @shop.update(shop_params)
      render json: @shop
    else
      render json: @shop.errors, status: :unprocessable_entity
    end
  end

  # DELETE /shops/1
  # DELETE /shops/1.json
  def destroy
    @shop.destroy
    render json: @shop
  end

  private

    def set_shop
      @shop = Shop.by_user(current_user).find(params[:id])
    end

    def shop_params
      params.require(:shop).permit(:shop_name,
                                   :contact_name,
                                   :contact_phone,
                                   :contact_phone2,
                                   :contact_address,
                                   :contact_address2,
                                   :contact_city,
                                   :contact_state_province,
                                   :contact_postal_code,
                                   :contact_email)
    end
end

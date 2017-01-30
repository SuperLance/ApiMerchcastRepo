class Api::ListingsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_listing, only: [:show, :update, :destroy]

  # GET /listings
  # GET /listings.json
  def index
    @listings = Listing.by_user(current_user).all

    render json: @listings
  end

  # GET /listings/1
  # GET /listings/1.json
  def show
    render json: @listing
  end

  # POST /listings
  # POST /listings.json
  def create
    @listing = Listing.new(listing_params)

    # check that the product has a print_image already created
    if @listing.product.print_image.file.nil?
      @listing.errors.add(:create, "Product must have a print_image to create a listing")
      render json: @listing.errors, status: :unprocessable_entity and return
    end

    current_user.listings << @listing

    if @listing.save
      store = Store.find(listing_params[:store_id])
      adapter = store.get_adapter
      @listing.external_id = adapter.list_product(@listing)
      @listing.printer_sku =  @listing.sku
      Rails.logger.debug "----------start------"
      Rails.logger.debug @listing.inspect
      Rails.logger.debug "----------start------"

      if @listing.save
        render json: @listing, status: :created
      else
        render json: @listing.errors, status: :unprocessable_entity
      end
    else
      render json: @listing.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /listings/1
  # PATCH/PUT /listings/1.json
  # def update
  #   @listing = Listing.find(params[:id])

  #   if @listing.update(listing_params)
  #     render json: @listing
  #   else
  #     render json: @listing.errors, status: :unprocessable_entity
  #   end
  # end

  # DELETE /listings/1
  # DELETE /listings/1.json
  def destroy
    @listing.destroy

    render json: @listing
  end

  private

    def set_listing
      @listing = Listing.by_user(current_user).find(params[:id])
    end

    def listing_params
      params.require(:listing).permit(:product_id, :store_id)
    end
end

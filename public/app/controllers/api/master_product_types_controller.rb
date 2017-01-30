class Api::MasterProductTypesController < ApplicationController
  before_action :authenticate_user!
  before_action :check_admin, except: [:index, :show]
  before_action :set_master_product_type, only: [:show, :update, :destroy]

  # GET /master_product_types
  # GET /master_product_types.json
  def index
    @master_product_types = MasterProductType.all

    render json: @master_product_types
  end

  # GET /master_product_types/1
  # GET /master_product_types/1.json
  def show
    render json: @master_product_type
  end

  # POST /master_product_types
  # POST /master_product_types.json
  def create
    @master_product_type = MasterProductType.new(master_product_type_params)

    if @master_product_type.save
      render json: @master_product_type, status: :created
    else
      render json: @master_product_type.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /master_product_types/1
  # PATCH/PUT /master_product_types/1.json
  def update
    @master_product_type = MasterProductType.find(params[:id])

    if @master_product_type.update(master_product_type_params)
      render json: @master_product_type
    else
      render json: @master_product_type.errors, status: :unprocessable_entity
    end
  end

  # DELETE /master_product_types/1
  # DELETE /master_product_types/1.json
  def destroy
    @master_product_type.destroy

    render json: @master_product_type
  end

  private

    def set_master_product_type
      @master_product_type = MasterProductType.find(params[:id])
    end

    def master_product_type_params
      params.require(:master_product_type).permit(:name, 
                                                  :valid_sizes, 
                                                  :valid_colors, 
                                                  :spreadshirt_support, 
                                                  :pwinty_suppport)
    end
end

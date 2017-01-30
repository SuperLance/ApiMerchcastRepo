class Api::StoresController < ApplicationController
  before_action :authenticate_user!
  before_action :set_store, only: [:show, :update, :destroy]

  # GET /stores
  # GET /stores.json
  def index
    if current_user.admin?
      @stores = Store.all
    else
      @stores = current_user.stores
    end

    render json: @stores
  end

  # GET /stores/1
  # GET /stores/1.json
  def show
    render json: @store
  end

  # POST /stores
  # POST /stores.json
  def create
    @store = Store.new(store_params)

    @store.api_path = @store.name unless @store.api_path.present?

    # make sure the store can connect to shopify
    # will return 4xx code if shopify login is bad
    # 401 is bad api secret
    # 403 is bad api key
    # 404 implies bad store name

    # validate the return code
    adapter = @store.get_adapter
    return_data = adapter.validate_store(@store)
    if return_data[:return_code] != 200
      render json: return_data, :status => return_data[:return_code] and return
    end

    current_user.stores << @store

    if @store.save
      render json: @store, status: :created
    else
      render json: @store.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /stores/1
  # PATCH/PUT /stores/1.json
  def update
    if @store.update(store_params)
      render json: @store
    else
      render json: @store.errors, status: :unprocessable_entity
    end
  end

  # DELETE /stores/1
  # DELETE /stores/1.json
  def destroy
    @store.destroy

    render json: @store
  end

  private

    def set_store
      @store = Store.by_user(current_user).find(params[:id])
    end

    def store_params
      params.require(:store).permit(:store_type, :name, :description, :api_key, :api_secret, :api_path)
    end
end

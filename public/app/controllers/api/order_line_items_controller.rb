class Api::OrderLineItemsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_order_line_item, only: [:show, :update, :destroy]
  before_action :set_order

  # GET /order_line_items
  # GET /order_line_items.json
  def index
    @order_line_items = @order.order_line_items

    render json: @order_line_items
  end

  # GET /order_line_items/1
  # GET /order_line_items/1.json
  def show
    render json: @order_line_item
  end

  # POST /order_line_items
  # POST /order_line_items.json
  # def create
  #   @order_line_item = OrderLineItem.new(order_line_item_params)

  #   if @order_line_item.save
  #     render json: @order_line_item, status: :created, location: @order_line_item
  #   else
  #     render json: @order_line_item.errors, status: :unprocessable_entity
  #   end
  # end

  # PATCH/PUT /order_line_items/1
  # PATCH/PUT /order_line_items/1.json
  def update
    @order_line_item = OrderLineItem.find(params[:id])

    if @order_line_item.update(order_line_item_params)
      # set to manually completd
      @order_line_item.status = "Manually Completed"
      @order_line_item.save
      render json: @order_line_item
    else
      render json: @order_line_item.errors, status: :unprocessable_entity
    end
  end

  # DELETE /order_line_items/1
  # DELETE /order_line_items/1.json
  # def destroy
  #   @order_line_item.destroy

  #   head :no_content
  # end

  private

    def set_order_line_item
      @order_line_item = OrderLineItem.by_user(current_user).find(params[:id])
    end

    def set_order
      @order = Order.by_user_admin_all(current_user).find(params[:order_id])
    end

    def order_line_item_params
      params.require(:order_line_item).permit(:tracking, :tracking_url, :shipping_type, :shipping_description)
    end
end

class Api::OrdersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_order, only: [:show, :update, :destroy, :source_order, :order_details]

  # GET /orders
  # GET /orders.json
  def index

    # handle admin user
    # see if we need to limit to orders from a specific customer
    if params[:customer].present?
      @orders = Customer.by_user(current_user).find(params[:customer]).orders
    else
      # check if we are just getting closed orders
      if params[:filter].present? and params[:filter].downcase == "completed"
        @orders = Order.by_user_admin_all(current_user).completed
      elsif params[:filter].downcase == "all" or params[:filter].downcase == "received" 
        #
        # Check stores for new orders
        #
        # get the stores for which to update orders
        if current_user.admin?
          stores = Store.all
        else
          stores = current_user.stores
        end

        # update from each store
        if !stores.nil?
          stores.each do |store|
            begin
              update_orders_from_source(store)
            rescue => e
              print e
            end
          end
        end

        ##========== *balance status check* ===========##
        if current_user.admin?
          @users = User.all
        else
          @users = [current_user]
        end

        if !@users.nil?
          @users.each do |user|
            if !user.orders.nil?
              sum_price = 0
              user.orders.each do |order|
                sum_price += order.price 
              end
              if !user.balances[0].nil? and sum_price.to_f < user.balances[0].balance.to_f
                user.orders.each do |order|
                  order.fund_status = true
                  order.save
                end
              else
                user.orders.each do |order|
                  order.fund_status = false
                  order.save
                end
              end
            end
          end 
        end
        ##========== ***** ==========##
        #
        # Get the orders based on filter
        #
        if params[:filter].present? and params[:filter].downcase == "all"
          # get all orders
          @orders = Order.by_user_admin_all(current_user).all
        else
          # get current orders
          @orders = Order.by_user_admin_all(current_user).received
        end
      else
        fulfill_service = FulfillService.new
        if current_user.admin? and params[:filter].downcase == "fulfill"
          fulfill_service.fulfill_orders
        elsif current_user.admin? and params[:filter].downcase == "submit"
          fulfill_service.submit_printer_orders
        elsif current_user.admin? and params[:filter].downcase == "update"
          fulfill_service.update_printer_order_status
        elsif current_user.admin? and  params[:filter].downcase == "save"
          fulfill_service.sync_fulfillment_info
        else

        end
        @orders = Order.by_user_admin_all(current_user).all
      end
    end

    render json: @orders
  end

  # GET /orders/1
  # GET /orders/1.json
  def show
    render json: @order
  end

  # POST /orders
  # POST /orders.json
  # def create
  #   @order = Order.new(order_params)
  #
  #   if @order.save
  #     render json: @order, status: :created, location: @order
  #   else
  #     render json: @order.errors, status: :unprocessable_entity
  #   end
  # end

  # PATCH/PUT /orders/1
  # PATCH/PUT /orders/1.json
  def update
    if @order.update(order_params)
      render json: @order
    else
      render json: @order.errors, status: :unprocessable_entity
    end
  end

  # DELETE /orders/1
  # DELETE /orders/1.json
  # def destroy
  #   @order.destroy
  #
  #   head :no_content
  # end

  # GET /orders/1/source_order
  # returns the order data from the external store
  def source_order

    # get the shopify order
    adapter = @order.store.get_adapter
    @source_order = adapter.get_order(@order.store, @order.external_order_id)

    @source_order.id = @order.id unless @source_order.nil?

    render json: @source_order
  end

  def stats

    @order_stats = OrderStats.new

    @order_stats.user_id = current_user.id

    # orders for today
    todays_orders = Order.by_user_admin_all(current_user).orders_today
    @order_stats.today_count = todays_orders.length
    @order_stats.today_total = sum_orders(todays_orders)
    @order_stats.today_change = @order_stats.today_total / sum_orders(Order.orders_previous_day) * 100
    @order_stats.today_profit = get_orders_profit(todays_orders)

    # orders over last 7 days
    seven_day_orders = Order.by_user_admin_all(current_user).orders_this_week
    @order_stats.seven_day_count = seven_day_orders.length
    @order_stats.seven_day_total = sum_orders(seven_day_orders)
    @order_stats.seven_day_change = @order_stats.seven_day_total / sum_orders(Order.orders_previous_week) * 100
    @order_stats.seven_day_profit = get_orders_profit(seven_day_orders)

    # orders over last 30 days
    thirty_day_orders = Order.by_user_admin_all(current_user).orders_this_month
    @order_stats.thirty_day_count = thirty_day_orders.length
    @order_stats.thirty_day_total = sum_orders(thirty_day_orders)
    @order_stats.thirty_day_change = @order_stats.thirty_day_total / sum_orders(Order.orders_previous_month) * 100
    @order_stats.thirty_day_profit = get_orders_profit(thirty_day_orders)

    render json: @order_stats
  end

  def billing_stats
    @stats = []

    if current_user.admin
      users = User.all
    else
      users = [current_user]
    end

    users.each do |user|
      @bs = BillingStats.new
      @bs.user_id = user.id

      orders_this_month_aligned = Order.by_user(user).orders_this_month_aligned
      @bs.this_month_count = orders_this_month_aligned.length
      @bs.this_month_total = sum_orders(orders_this_month_aligned)

      orders_last_month_aligned = Order.by_user(user).orders_last_month_aligned
      @bs.last_month_count = orders_last_month_aligned.length
      @bs.last_month_total = sum_orders(orders_last_month_aligned)

      @stats << @bs
    end

    render json: @stats, root: "billing_stats"
  end


  # GET /orders/1/order_details
  # returns the order data from the external store
  def order_details
    # get the shopify order
    adapter = @order.store.get_adapter
    @source_order = adapter.get_order(@order.store, @order.external_order_id)
    @source_order.id = @order.id unless @source_order.nil?

    # get our OrderDetailsData object that holds all of the related data
    @order_details_data = OrderDetailsData.new

    # set our order data
    @order_details = OrderDetails.new(@order)
    @order_details.source_order = @source_order
    @order_details_data.order_details = @order_details

    # handle all of the line items.  Not as simple as just setting to the array
    # since the order_line_items and source_order_line_items need to be correlated!
    # since the order_line_items were originally created from the
    # source_order_line_items we can assume they all match
    @order.order_line_items.each do |oli|
      # create the line item and add it to the OrderDetails
      details_line_item = OrderDetailsLineItem.new(oli)
      @order_details.line_items << details_line_item

      # now pair it up with the SourceOrderLineItem
      # leave it as nil if there is not a match
      @source_order.line_items.each do |sli|
        # make sure to cast the SourceOrderLineItem external_id to a string
        # it will usually be an Integer for Shopify orders
        if sli.external_id.to_s == oli.external_id
          # found our match so break out of it
          details_line_item.source_order_line_item= sli
          break
        end
      end
    end

    # set our customer related data
    @order_details_data.customer = @order.customer
    @order_details_data.customer_orders = @order.customer.orders

    render json: @order_details_data
  end

  private

    def sum_orders(orders)
      total = 0.0
      orders.each do |o|
        total += o.price unless o.price.nil?
      end

      return total
    end

    def get_orders_profit(orders)
      total = 0.0
      orders.each do |o|
        o.order_line_items.each do |oli|
          begin
            total += oli.price - oli.listing.product.master_product.printer_price if oli.listing
          rescue => e
            print e # perhaps because one of the prices was null
          end
        end
      end
      return total
    end

    def update_orders_from_source(store)
      adapter = store.get_adapter
      source_orders = adapter.get_orders(store)
      if !source_orders.nil?
        source_orders.each do |o|
          if !Order.where(store_id: store.id, external_order_id: o.external_order_id).exists?
            customer = Customer.find_or_create_from_source_order(store, o)

            order = Order.create(user_id: store.user_id,
                                store_id: store.id,
                                external_order_id: o.external_order_id,
                                external_order_name: o.order_name,
                                order_date: o.created_at,
                                print_status: Order::PRINT_STATUS_NEW,
                                tracking: "",
                                price: o.total_price,
                                status: "Received" )

            # make sure to check for nil - will be nil if source order did not have a customer (anonymous checkout)
            customer.orders << order unless customer.nil?
            if o.line_items.present?
              o.line_items.each do |li|                size = nil
                if (li.variant_title.index('/')) # A variant title could include both a size and a color
                  parts = li.variant_title.split('/')
                  color_title = parts[0].strip
                  size_title = parts[1].strip
                else
                  color_title = li.variant_title
                end
                color = MasterProductColor.by_name(color_title) if color_title
                size = MasterProductSize.by_name(size_title) if size_title

                line_item = OrderLineItem.new(user_id: store.user_id,
                                              external_id: li.external_id,
                                              master_product_color_id: color.id,
                                              master_product_size_id: size.id,
                                              price: li.price,
                                              quantity: li.quantity)
              
                if li.sku.present?
                  begin
                    listing = Listing.where(printer_sku: li.sku)[0]
                    listing.order_line_items << line_item
                    line_item.status = "Received"
                  rescue => e
                    print e
                    # did not find the sku, or something else went wrong, so mark as unmatched
                    line_item.status = "Unmatched"
                  end
                else
                  # need to issue warning that we have an order we can't tie back to a listing
                  line_item.status = "Unmatched"
                end

                order.order_line_items << line_item
                line_item.save
              end
            end

            if o.shipping_address.present?
              order.shipping_name = o.shipping_address.name
              order.shipping_address = o.shipping_address.address1
              order.shipping_address2 = o.shipping_address.address2 if o.shipping_address.address2.present?
              order.shipping_city = o.shipping_address.city
              order.shipping_state = o.shipping_address.province
              order.shipping_country = o.shipping_address.country
              order.shipping_postal_code = o.shipping_address.zip
              order.shipping_state_code = o.shipping_address.province_code
              order.shipping_country_code = o.shipping_address.country_code
            end

            order.save
          end
        end
      end
    end

    def set_order
      @order = Order.by_user_admin_all(current_user).find(params[:id])
    end

    def order_params
      params.require(:order).permit(:tracking)
    end
end

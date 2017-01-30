require 'shopify_api'

class ShopifyAdapter
  SHOPIFY_MAX_VARIANTS = 100

  def init_session(store)
    # defensively clear the shopify session in case it was left intact
    ShopifyAPI::Base.clear_session

    url = 'https://' + store.api_key + ':' + store.api_secret +
      '@' + store.api_path + '.myshopify.com/admin'
    ShopifyAPI::Base.site = URI.encode(url)
  end

  def end_session
    # clear the shopify sessionfor next use
    ShopifyAPI::Base.clear_session
  end


  # get orders from a Shopify store
  def get_orders(store)

    init_session(store)

    orders = ShopifyAPI::Order.all

    end_session

    return map_source_orders(orders)
  end

  # get a specific order from Shopify
  # it needs the store for the connection parameters, including store name
  #
  def get_order(store, shopify_order_id)

    init_session(store)

    order = ShopifyAPI::Order.find(shopify_order_id)

    end_session

    return map_source_order(order)
  end

  # validate that a store can talk to shopify
  # makes sure that the api_key, api_secret, and api_path
  # are valid.
  #
  def validate_store(store)
    return_data = {}

    begin
      orders = get_orders(store)

      # a bad api path shows up as a nil when orders are returned
      if orders.empty?
        return_data[:return_code] = 404
      return_data[:error_message] = "Either the store name was not found, or there are no orders for the store."
      else
        # we got orders or an empty list, so all is good
        return_data[:return_code] = 200
      end
    rescue ActiveResource::ForbiddenAccess => e
      # bad api key
      return_data[:return_code] = 403
      return_data[:error_message] = "The api key was not valid"
    rescue ActiveResource::UnauthorizedAccess => e
      # bad api secret
      return_data[:return_code] = 401
      return_data[:error_message] = "The api secret was not valid"
    rescue ActiveResource::ConnectionError => e
      # some sort of connection error
      return_data[:return_code] = 400
      return_data[:error_message] = e.response
    rescue => e
      puts e
      puts e.backtrace
      return_data[:return_code] = 500
      return_data[:error_message] = "Unknown error"
    end

    return return_data
  end

  def get_customer(order)
    return order.customer
  end

  def list_product(listing)
    init_session(listing.store)

    product = listing.product

    # Create the new product and save it
    sp = ShopifyAPI::Product.new
    sp.title = product.title
    sp.product_type = product.master_product.master_product_type.name
    sp.body_html = product.description
    sp.save
    sp.errors.full_messages.each {|msg| print "ERROR_CREATING_SHOPIFY: " + msg + "\n"}

    # geting selected sizes
    size_ids = product.product_size_ids.split(',')
    product_sizes = [];
    size_ids.each do |size_id|
      product.master_product.master_product_sizes.each do |master_size|
        if size_id.to_i == master_size.id
          product_sizes.push(master_size)
        end
      end
    end
    
    sizes = product_sizes.map(&:name).sort
    colors = product.product_variant_images.map(&:name).sort

    # now that the product has been initialized on shopify, upload the images, add the variants, and save it
    sp.images << {src: product.product_image.url} unless (product.product_image.nil? || colors.any?)
    sp.save
    sp.errors.full_messages.each {|msg| print "ERROR_SETTING_SHOPIFY_IMAGE: " + msg + "\n"}

    variant = sp.variants.first
    variant.title = get_title(colors.first, sizes.first)
    variant.sku = listing.sku
    variant.inventory_quantity = get_inventory_quantity(product, colors.first, sizes.first)
    if variant.inventory_quantity.present?
      variant.fulfillment_service = "manual"
      variant.inventory_management = "shopify"
    end
    variant.option1 = get_option1(colors.first, sizes.first)
    variant.option2 = get_option2(colors.first, sizes.first)
    variant.price = product.price
    variant.save

    if (colors.any? || sizes.any?)
      sp.options = []
      sp.options << ShopifyAPI::Option.new(:name => "Color") if colors.any?
      sp.options << ShopifyAPI::Option.new(:name => "Size") if sizes.any?
    end

    sp.save
    sp.errors.full_messages.each {|msg| print "ERROR_FIRST_VARIANT_AND_OPTIONS: " + msg + "\n"}

    # Associate image URLs with colors
    color_images = {}
    product.product_variant_images[0..-1].each do |color_obj|
      color_images[color_obj.name] = color_obj.image.url
    end

    colors_and_sizes = get_colors_and_sizes(colors, sizes)

    colors_and_sizes.each do |color_and_size|
      color = color_and_size[0]
      size = color_and_size[1]

      new_variant = ShopifyAPI::Variant.new(
        title: get_title(color, size),
        price: product.price,
        sku: listing.sku,
        option1: get_option1(color, size),
        option2: get_option2(color, size),
        inventory_quantity: get_inventory_quantity(product, color, size),

      )
      if variant.inventory_quantity.present?
        new_variant.fulfillment_service = "manual";
        new_variant.inventory_management = "shopify";
      end

      sp.variants << new_variant
    end
    sp.save
    sp.errors.full_messages.each {|msg| print "ERROR_CREATING_A_VARIANT: " + msg + "\n"}

    variants_for_color = {}

    if (colors.any?)
      sp.variants.each do |v|
        (variants_for_color[v.option1] ||= []).push(v.id)
      end
    end

    variants_for_color.each do |vfc|
      (sp.images ||= []).push({src: color_images[vfc[0]], variant_ids: vfc[1] })
    end

    sp.save
    sp.errors.full_messages.each {|msg| print "ERROR_AFTER_SAVING_IMAGES: " + msg + "\n"}

    end_session

    return sp.id
  end

  def remove_listing(listing)
    init_session(listing.store)

    begin
      sp = ShopifyAPI::Product.find(listing.external_id)
      sp.destroy
    rescue => e
      print e
    end

    end_session
  end

  def sync_fulfillment_info(order_line_item)
    init_session(order_line_item.order.store)

    f = ShopifyAPI::Fulfillment.new(:order_id => order_line_item.order.external_order_id,
                                    :tracking_number => order_line_item.tracking,
                                    :tracking_url => order_line_item.tracking_url,
                                    :line_items => [{"id" => order_line_item.external_id}])
    success = f.save

    end_session

    return success
  end


  private

    def get_title(color, size)
      title = ''
      title += color if color.present?
      title += ' ' if color.present? && size.present?
      title += size if size.present?

      return title
    end

    # This exists because we need to iterate differently depending
    # on if there are colors, sizes, neither, or both
    def get_colors_and_sizes(colors, sizes)
      colors_result = []
      sizes_result = []

      count = 0

      # Shopify has a limit of 100 variants; we'll show as many colors as we can where we can show all sizes
      if colors.any? && sizes.any?
        max_color = [colors.length, (SHOPIFY_MAX_VARIANTS / sizes.length).floor].min - 1
        colors[0..max_color].each do |color|
          sizes[0..-1].each do |size|
            count += 1
            next if (count == 1) # first variant was already taken care of
            break if (count >= SHOPIFY_MAX_VARIANTS)
            colors_result << color
            sizes_result << size
          end
        end
      elsif colors.any?
        max_color = [colors.length, SHOPIFY_MAX_VARIANTS].max
        colors[0..max_color].each do |color|
          count += 1
          next if (count == 1)
          colors_result << color
          sizes_result << nil
        end
      elsif sizes.any?
        sizes[0..-1].each do |size|
          count += 1
          next if (count == 1)
          colors_result << nil
          sizes_result << size
        end
      else
        # do nothing since there should be just the first value
        return []
      end

      return colors_result.zip(sizes_result)
    end

    def get_option1(color, size)
      return color if color.present?
      return size if size.present?
      return nil
    end

    def get_option2(color, size)
      return size if color.present? && size.present?
      return nil

    end

    def get_inventory_quantity(product, color, size)
      begin
        inventory = product.master_product.master_product_stock_states.where(color:color,size:size)
        return inventory.any? ? inventory[0].quantity : nil
      rescue => e
        print e
        return nil
      end
    end

    def map_address(address)
      sa = SourceAddress.new
      sa.first_name = address.first_name if address.respond_to? :first_name
      sa.last_name = address.last_name if address.respond_to? :last_name
      sa.name = address.name if address.respond_to? :name
      sa.address1 = address.address1 if address.respond_to? :address1
      sa.address2 = address.address2 if address.respond_to? :address2
      sa.city = address.city if address.respond_to? :city
      sa.province = address.province if address.respond_to? :province
      sa.country = address.country if address.respond_to? :country
      sa.zip = address.zip if address.respond_to? :zip
      sa.phone = address.phone if address.respond_to? :phone
      sa.company = address.company if address.respond_to? :company
      sa.province_code = address.province_code if address.respond_to? :province_code
      sa.country_code = address.country_code if address.respond_to? :country_code

      return sa
    end

    def map_customer(customer)
      sc = SourceCustomer.new
      sc.external_id = customer.id if customer.respond_to? :id
      sc.email = customer.email if customer.respond_to? :email
      sc.first_name = customer.first_name if customer.respond_to? :first_name
      sc.last_name = customer.last_name if customer.respond_to? :last_name
      sc.orders_count = customer.orders_count if customer.respond_to? :orders_count
      sc.total_spent = customer.total_spent if customer.respond_to? :total_spent

      if (customer.respond_to? :default_address) and customer.default_address.present?
        sc.default_address  = map_address(customer.default_address)
        sc.phone = customer.default_address.phone if customer.default_address.respond_to? :phone
      end

      return sc
    end

    def map_shipping_lines(shipping_line)
      sl = SourceShippingLine.new
      sl.external_id = shipping_line.id if shipping_line.respond_to? :id
      sl.title = shipping_line.title if shipping_line.respond_to? :title
      sl.price = shipping_line.price if shipping_line.respond_to? :price
      sl.code = shipping_line.code if shipping_line.respond_to? :code
      sl.carrier = shipping_line.carrier_identifier if shipping_line.respond_to? :carrier_identifier

      return sl
    end

    def map_order_line_items(line_item)
      sl = SourceOrderLineItem.new
      sl.external_id = line_item.id if line_item.respond_to? :id
      sl.variant_id = line_item.variant_id if line_item.respond_to? :variant_id
      sl.title = line_item.title if line_item.respond_to? :title
      sl.quantity = line_item.quantity if line_item.respond_to? :quantity
      sl.price = line_item.price if line_item.respond_to? :price
      sl.sku = line_item.sku if line_item.respond_to? :sku
      sl.variant_title = line_item.variant_title if line_item.respond_to? :variant_title
      sl.vendor = line_item.vendor if line_item.respond_to? :vendor
      sl.external_product_id = line_item.product_id if line_item.respond_to? :product_id
      sl.name = line_item.name if line_item.respond_to? :name
      sl.total_discount = line_item.total_discount if line_item.respond_to? :total_discount
      sl.fulfillment_status = line_item.fulfillment_status if line_item.respond_to? :fulfillment_status

      return sl
    end

    def map_source_order(order)
      so = SourceOrder.new

      Rails.logger.debug {"Working Shopify order id #{order.id}"}

      # don't check for field existence here because we want it to
      # fail if the order id is not there
      so.external_order_id = order.id

      so.email = order.email if order.respond_to? :email
      so.created_at = order.created_at if order.respond_to? :created_at
      so.updated_at = order.updated_at if order.respond_to? :updated_at
      so.closed_at = order.closed_at if order.respond_to? :closed_at
      so.note = order.note if order.respond_to? :note
      so.total_price = order.total_price if order.respond_to? :total_price
      so.subtotal_price = order.subtotal_price if order.respond_to? :subtotal_price
      so.total_weight = order.total_weight if order.respond_to? :total_weight
      so.total_tax = order.total_tax if order.respond_to? :total_tax
      so.currency = order.currency if order.respond_to? :currency
      so.financial_status = order.financial_status if order.respond_to? :financial_status
      so.confirmed = order.confirmed if order.respond_to? :confirmed
      so.total_disounts = order.total_discounts if order.respond_to? :total_discounts
      so.order_name = order.name if order.respond_to? :name1
      so.fulfillment_status = order.fulfillment_status if order.respond_to? :fulfillment_status
      so.order_status_url = order.order_status_url if order.respond_to? :order_status_url

      # map addresses
      so.billing_address = map_address(order.billing_address) if order.respond_to? :billing_address
      so.shipping_address = map_address(order.shipping_address) if order.respond_to? :shipping_address

      # map customer
      so.customer = map_customer(order.customer) if order.respond_to? :customer and order.customer.present?

      # map shipping line items
      so.shipping_lines = []
      if (order.respond_to? :shipping_lines) and order.shipping_lines.present?
        order.shipping_lines.each do |shipping_line|
          so.shipping_lines << map_shipping_lines(shipping_line)
        end
      end

      so.line_items = []
      if (order.respond_to? :line_items) and order.line_items.present?
        order.line_items.each do |li|
          so.line_items << map_order_line_items(li)
        end
      end

      so.raw_order_data = order.as_json

      return so
    end

    def map_source_orders(orders)
      mapped_orders = []

      if !orders.nil?
        orders.each do |order|
          mapped_orders << map_source_order(order)
        end
      end

      return mapped_orders
    end
end

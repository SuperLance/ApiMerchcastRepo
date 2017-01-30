require 'bigcommerce'
require 'state_mapper'

class BigcommerceAdapter
  def setup(store)
    Bigcommerce.configure do |config|
      config.auth = 'legacy'
      config.url = 'https://' + store.api_path + '.mybigcommerce.com/api/v2/'
      config.username = store.api_key
      config.api_key = store.api_secret
    end
  end

  def get_orders(store)

    # setup connection
    setup(store)

    orders = Bigcommerce::Order.all

    # teardown connection

    return map_source_orders(orders)
  end


  def get_order(store, bigcommerce_order_id)
    # setup connection
    setup(store)

    order = Bigcommerce::Order.find(bigcommerce_order_id)

    # teardown connection

    # make sure to do the deep mapping since we need it to make
    # multiple calls to retrieve all of the data we need
    return map_source_order_deep(order)
  end

  # validate that a store can talk to bigcommerce
  # makes sure that the api_key, api_secret, and api_path
  # are valid.
  #
  def validate_store(store)
    return_data = {}

    begin
      orders = get_orders(store)

      # a bad store name shows up as a nil when orders are returned
      if orders.nil?
        return_data[:return_code] = 404
      else
        # we got orders or an empty list, so all is good
        return_data[:return_code] = 200
      end
    rescue Faraday::ConnectionFailed => e
      return_data[:return_code] = 404
      return_data[:error_message] = "The API Path could not be found"
    rescue Bigcommerce::Unauthorized => e
      # bad api key or secret
      return_data[:return_code] =  401
      return_data[:error_message] = "The API credentials are not valid"
    rescue => e
      puts e
      puts e.backtrace
      return_data[:return_code] = 500
      return_data[:error_message] = "Unknown error"
    end

    return return_data
  end

  def get_customer(source_order)
    source_customer = get_source_customer_from_source_order(source_order)

    return source_customer
  end

  def list_product(listing)
    # setup connection
    setup(listing.store)

    product = listing.product

    # the last category returned from Bigcommerce seems to be the default,
    # so use it
    cat = Bigcommerce::Category.all.last

    colors = product.product_variant_images.map(&:name).sort
    sizes = product.master_product.master_product_sizes.map(&:name).sort

    # creating options workflow:
    # 1. create option
    # 2. create option value and link to option (#1)
    # 3. create option set
    # 4. link option (#1) to option set (#3) by creating option_set_option

    # 1. create options
    option = Bigcommerce::Option.create(
      name: "#{listing.id}-colors-opt",
      display_name: "color",
      type: 'S', # This was CU [as defined here: http://stackoverflow.com/questions/36484418/what-are-the-option-types-for-creating-options-in-the-bigcommerce-api] but we would need to add the hex for unsupported colors
    )

    option2 = Bigcommerce::Option.create(
      name: "#{listing.id}-size-opt",
      display_name: "size",
      type: 'S',
    )

    # 2. create option value and link to option (#1)
    colors.each do |color|
      begin
        Bigcommerce::OptionValue.create(
          option.id,
          label: "#{listing.id}-#{color}",
          value: color
        )
      rescue
        Rails.logger.error {"Could not create color option #{color} for BigCommerce"}
      end
    end

    sizes.each do |size|
      begin
        Bigcommerce::OptionValue.create(
          option2.id,
          label: "#{listing.id}-#{size}",
          value: size
        )
      rescue
        Rails.logger.error {"Could not create size option #{size} for BigCommerce"}
      end
    end

    # 3. create option set
    option_set = Bigcommerce::OptionSet.create(
      name: "#{listing.id}-color-opt-set"
    )

    # 4. link option (#1) to option set (#3) by creating option_set_option
    option_set_option = Bigcommerce::OptionSetOption.create(
      option_set.id,
      option_id: option.id,
      display_name: "#{listing.id}-color-opt-set-opt"
    )

    option_set_option = Bigcommerce::OptionSetOption.create(
      option_set.id,
      option_id: option2.id,
      display_name: "#{listing.id}-size-opt-set-opt"
    )

    # Create the product on bigcommerce.
    # They require weight, which we do not get from the printers,
    # so default it to 16oz
    title_suffix = ''
    title_num = 1
    created = false
    sku_suffix = ''
    sku_num = 1
    while !created do
      begin
        bcp = Bigcommerce::Product.create(name: product.title + title_suffix,
                                          type: 'physical',
                                          description: product.description,
                                          price: product.price,
                                          availability: 'available',
                                          categories: [cat.id],
                                          weight: '16',
                                          sku: listing.sku + sku_suffix,
                                          option_set_id: option_set.id,
                                          is_visible: true)
        created = true
      rescue => e
          print e
          if (e.message.index('product with the name'))
            # If a product with this name already exists, add a number to the end of the product name
            title_num += 1
            title_suffix = " " + title_num.to_s
          elsif (e.message.index('product with the sku value of'))
            # If a sku with this name already exists, add a number to the end of the sku
            sku_num += 1
            sku_suffix = "_" + sku_num.to_s
          else
            return
          end
      end
    end

    # set the image for the product (if not done so via colors)
    if product.product_image.present? && (colors.length == 0)
      begin
        bcpi = Bigcommerce::ProductImage.create(bcp.id,
                                                image_file: product.product_image.url)
      rescue => e
        Rails.logger.error { "Error creating product image for Bigcommerce product listing: #{e.message} #{e.backtrace.join("\n")}" }
      end
    end

    product.product_variant_images.each do |color_obj|
      begin
        bcpi = Bigcommerce::ProductImage.create(bcp.id,
                                                image_file: color_obj.image_url)
      rescue => e
        Rails.logger.error { "Error creating product image for Bigcommerce product listing for color {color_obj.name}: #{e.message} #{e.backtrace.join("\n")}" }
      end
    end

    return bcp.id
  end

  def remove_listing(listing)
    # setup connection
    setup(listing.store)
    if listing.external_id
      return Bigcommerce::Product.destroy(listing.external_id)
    else
      return false
    end

  end

  def sync_fulfillment_info(order_line_item)
    # setup connection
    setup(order_line_item.order.store)

    # for now, it is ok to set quantity to the OrderLineItem quantity since
    # our only printer does not do partial line-item fulfillment
    # first we hve to get the id of the shipping address - always the first one for the order
    order_address = Bigcommerce::OrderShippingAddress.all(order_line_item.order.external_order_id.to_i)[0]
    success = Bigcommerce::Shipment.create(order_line_item.order.external_order_id.to_i,
                                           tracking_number: order_line_item.tracking,
                                           comments: "",
                                           order_address_id: order_address.id,
                                           items: [{order_product_id: order_line_item.external_id,
                                                    quantity: order_line_item.quantity}])

    return success
  end



  private


  # line items are called OrderProducts on Bigcommerce
  def map_order_line_items(line_item)
    sl = SourceOrderLineItem.new
    sl.external_id = line_item.id
    # sl.variant_id = line_item.variant_id
    sl.title = line_item.name
    sl.quantity = line_item.quantity
    sl.price = line_item.base_price
    sl.sku = line_item.sku
    sl.variant_title = line_item.product_options
    # sl.vendor = line_item.vendor
    sl.external_product_id = line_item.product_id
    sl.name = line_item.name
    sl.total_discount = line_item.applied_discounts
    # sl.fulfillment_status = line_item.fulfillment_status

    return sl
  end

  def map_address(address)
    sa = SourceAddress.new
    sa.first_name = address[:first_name]
    sa.last_name = address[:last_name]
    sa.name = sa.first_name + ' ' + sa.last_name
    sa.address1 = address[:street_1]
    sa.address2 = address[:street_2]
    sa.city = address[:city]
    sa.province = address[:state]
    sa.country = address[:country]
    sa.zip = address[:zip]
    sa.phone = address[:phone]
    sa.company = address[:company]
    sa.country_code = address[:country_iso2]
    sa.province_code = StateMapper::STATES[sa.province]
    return sa
  end

  def map_customer(customer)
    sc = SourceCustomer.new
    sc.external_id = customer.id
    sc.email = customer.email
    sc.first_name = customer.first_name
    sc.last_name = customer.last_name
    sc.phone = customer.phone
    # sc.orders_count = customer.orders_count
    # sc.total_spent = customer.total_spent

    # customer address is another call
    addresses = Bigcommerce::CustomerAddress.all(customer.id)
    sc.default_address  = map_address(addresses.first) if addresses.present?

    return sc
  end

  def map_source_order(order)
    so = SourceOrder.new

    so.external_order_id = order.id
    so.email = order.billing_address[:email] unless order.billing_address.nil?
    so.created_at = order.date_created
    so.updated_at = order.date_modified
    # so.closed_at = order.closed_at
    # so.note = order.note
    so.total_price = order.total_inc_tax
    so.subtotal_price = order.subtotal_ex_tax
    # so.total_weight = order.total_weight
    so.total_tax = order.total_tax
    so.currency = order.currency_code
    so.financial_status = order.payment_status
    # so.confirmed = order.confirmed
    so.total_disounts = order.discount_amount
    so.order_name = order.id
    so.fulfillment_status = order.status
    # so.order_status_url = order.order_status_url

    # map shipping line items directly from order
    so.shipping_lines = []
    # first is shipping
    sl1 = SourceShippingLine.new
    # sl.external_id = shipping_line.id
    sl1.title = "Shipping"
    sl1.price = order.shipping_cost_inc_tax
    # sl1.code = so.code
    # sl1.carrier = shipping_line.carrier_identifier
    so.shipping_lines << sl1
    # second is handling
    sl2 = SourceShippingLine.new
    # s2.external_id = shipping_line.id
    sl2.title = "Handling"
    sl2.price = order.handling_cost_inc_tax
    # sl2.code = so.code
    # sl2.carrier = shipping_line.carrier_identifier
    so.shipping_lines << sl2

    # map addresses
    so.billing_address = map_address(order.billing_address)

    # map the shipping address - makes another call but we need it to create order
    addresses = Bigcommerce::OrderShippingAddress.all(order.id)
    so.shipping_address = map_address(addresses.first) if addresses.present?

    sc = SourceCustomer.new
    sc.external_id = order.customer_id
    sc.email = so.email
    so.customer = sc

    # get them via Bigcommerce::OrderProduct.all(order_id)
    so.line_items = []
    products = Bigcommerce::OrderProduct.all(order.id)
    products.each do |li|
      so.line_items << map_order_line_items(li)
    end

    # add in the original order in case it is needed for anything
    so.raw_order_data = order.as_json

    return so
  end


  def map_source_orders(orders)
    mapped_orders = []

    orders.each do |order|
      mapped_orders << map_source_order(order)
    end

    return mapped_orders
  end

  # this method does a deep mapping, meaning that it follows the references
  # and makes multiple calls to fill in the rest of the details for the
  # order that we need
  def map_source_order_deep(order)
    so = map_source_order(order)

    # for now, skip shipping address since it is a new api call to retrieve it

    # map customer
    so.customer = get_source_customer_from_bigcommerce_order(order)

    # get them via Bigcommerce::OrderProduct.all(order_id)
    so.line_items = []
    products = Bigcommerce::OrderProduct.all(order.id)
    products.each do |li|
      so.line_items << map_order_line_items(li)
    end

    # map the shipping address
    addresses = Bigcommerce::OrderShippingAddress.all(order.id)
    so.shipping_address = map_address(addresses.first) if addresses.present?

    return so
  end

  def get_source_customer_from_source_order(order)
    # map customer
    # use order.customer_id to get id then Bigcommerce::Customer.find(id)
    customer = Bigcommerce::Customer.find(order.customer.external_id) if order.customer.present?
    if customer.present?
      source_customer = map_customer(customer)
    else
      source_customer = nil
    end

    return source_customer
  end

  def get_source_customer_from_bigcommerce_order(order)
    # map customer
    # use order.customer_id to get id then Bigcommerce::Customer.find(id)
    customer = Bigcommerce::Customer.find(order.customer_id) if order.customer_id.present?
    if customer.present?
      source_customer = map_customer(customer)
    else
      source_customer = nil
    end

    return source_customer
  end

end

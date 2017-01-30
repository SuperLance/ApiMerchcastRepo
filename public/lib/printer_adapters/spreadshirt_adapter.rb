require 'spreadshirt_client'
require 'nokogiri'
require 'open-uri'

class SpreadshirtAdapter

  def setup(printer)
    SpreadshirtClient.api_key = printer.api_key
    SpreadshirtClient.api_secret = printer.api_secret
    SpreadshirtClient.base_url = printer.url
  end

  # validate our connection by trying to complete a login via api
  # 404 indicates bad shop name
  # 401 indicates bad api_key or api_secret
  #
  def validate_connection(printer)
    return_data = login(printer)
    if return_data[:return_code] == 200
      # got here, all is good
      logout(return_data[:session_id])
    end

    return return_data
  end


  def login(printer)
    setup(printer)
    return_data = {}

    data = '<login xmlns:xlink="http://www.w3.org/1999/xlink" xmlns="http://api.spreadshirt.net"> ' +
           '<username>' + printer.user + '</username> ' +
           '<password>' + printer.password + '</password> </login>'

    begin
      results = SpreadshirtClient.post "/sessions", data
      doc = Nokogiri::XML(results)
      session_id = doc.children.first[:id]

      return_data[:session_id] = session_id
      return_data[:return_code] = 200

    rescue SocketError
      # bad url
      return_data[:return_code] = 404
      return_data[:error_message] = "Invalid url"
    rescue RestClient::Unauthorized => e
      # bad api secret or key, or invalid user name/password combination
      return_data[:return_code] = 401
      return_data[:error_message] = getErrorMessage(e)
    rescue RestClient::Exception => e
      # some sort of connection error
      return_data[:return_code] = 400
      return_data[:error_message] = getErrorMessage(e)
    rescue => e
      return_data[:return_code] = 500
      return_data[:error_message] = "Unknown error"
    end:error_message] = "Unknown error"
    end

    return return_data
  end

  def logout(session_id)
    url = "/sessions/" + session_id

    begin
      SpreadshirtClient.delete url
    rescue
      # do nothing - nothing can be done with orphan sessions
    end
  end

  def getErrorMessage(e))
    doc = Nokogiri::XML(e.response
    return doc.text.strip
  end

  def loadProductData(printer)

    data = SpreadshirtClient.get "/shops/#{printer.external_shop_id}/productTypes"
    doc = Nokogiri::XML(data)
    productTypes = doc.search('productType')

    productTypes.each do |pt|
      masterprod = MasterProduct.new
      printer.master_products << masterprod

      id = pt[:id]
      masterprod.external_id = id

      # get the details for the spreadshirt product
      url = pt.attributes["href"].value
      ptdata = SpreadshirtClient.get url
      ptdoc = Nokogiri::XML(ptdata)
      ptelement = ptdoc.children.first

      # category
      category = ptelement.css("/categoryName").text
      master_prod_type = MasterProductType.find_or_create_by(name: category)
      master_prod_type.master_products << masterprod

      # get field values
      masterprod.name = ptelement.css("/name").text
      masterprod.short_description = ptelement.css("/shortDescription").text
      masterprod.description = ptelement.css("/description").text
      masterprod.printer_price = ptelement.css("/price/vatIncluded").text
      masterprod.price = BigDecimal(masterprod.printer_price)

      # default image
      res = ptelement.search 'resource[type="preview"]'
      masterprod.default_image_url = res[0].attributes["href"].value

      # get our default image path so we can custom build color urls later
      lastslash = masterprod.default_image_url.rindex("/")
      default_image_base_url = masterprod.default_image_url[0..lastslash]


      # get the colors as product colors
      colors = ptelement.css '/appearances/appearance'
      colors.each do |c|
        mpcolor = MasterProductColor.new

        mpcolor.external_id = c[:id]

        # name
        nameelem = c.css '/name'
        mpcolor.name =  nameelem.text

        #image
        # don't use image in data - that is just a square of the color.
        # we want the image of the product in that color, which we need to custom build
        # res = c.css '/resources/resource'
        # mpcolor.image_url = res[0].attributes["href"].value
        mpcolor.image_url = default_image_base_url + mpcolor.external_id

        masterprod.master_product_colors << mpcolor
      end


      # get sizes
      sizes = ptelement.css '/sizes/size'
      sizes.each do |s|
        mpsize = MasterProductSize.new

        mpsize.external_id = s[:id]

        # name
        nameelem = s.css '/name'
        mpsize.name = nameelem.text

        masterprod.master_product_sizes << mpsize

      end

      # get image view data
      all_views_data = {}
      views = ptelement.css '/views/view'
      views.each do |v|
        view_data = {}

        view_data[:external_view_id] = v.attributes["id"].value

        nameelem = v.css '/name'
        view_data[:name] = nameelem.text

        widthelem = v.css '/size/width'
        view_data[:view_size_width] = Float(widthelem.text)

        heightelem = v.css '/size/height'
        view_data[:view_size_height] = Float(heightelem.text)

        # get print area offsets
        viewmapelem = v.css '/viewMaps/viewMap'
        xelem = viewmapelem.css 'offset/x'
        view_data[:offset_x] = Float(xelem.text)
        yelem = viewmapelem.css 'offset/y'
        view_data[:offset_y] = Float(yelem.text)

        # get image url
        res = v.css '/resources/resource'
        view_data[:image_url] = res[0].attributes["href"].value

        all_views_data[view_data[:external_view_id]] = view_data
      end

      # now get the print area data
      print_areas = ptelement.css '/printAreas/printArea'
      print_areas.each do |pa|
        mpprintarea = MasterProductPrintArea.new

        mpprintarea.external_id = pa.attributes["id"].value

        viewelem = pa.css 'defaultView'
        external_view_id = viewelem.first.attributes["id"].value
        mpprintarea.view_id = external_view_id
        viewdata = all_views_data[external_view_id]

        mpprintarea.name = viewdata[:name]
        mpprintarea.view_image_url = viewdata[:image_url]
        mpprintarea.view_size_width = viewdata[:view_size_width]
        mpprintarea.view_size_height = viewdata[:view_size_height]
        mpprintarea.offset_x = viewdata[:offset_x]
        mpprintarea.offset_y = viewdata[:offset_y]

        widthelem = pa.css '/boundary/size/width'
        mpprintarea.print_area_width = Float(widthelem.text)
        heightelem = pa.css '/boundary/size/height'
        mpprintarea.print_area_height = Float(heightelem.text)

        masterprod.master_product_print_areas << mpprintarea
      end

      masterprod.save
    end
  end

  def update_inventory(printer)
    data = SpreadshirtClient.get "/shops/#{printer.external_shop_id}/productTypes"
    doc = Nokogiri::XML(data)
    product_types = doc.search('productType')
    product_types.each do |pt|
      begin
        masterprod = MasterProduct.where(external_id: pt[:id])[0]

        if masterprod.present?
          masterprod.master_product_stock_states.delete_all if masterprod.master_product_stock_states.present?

          # get the details for the spreadshirt product
          url = pt.attributes["href"].value
          ptdata = SpreadshirtClient.get url
          ptdoc = Nokogiri::XML(ptdata)
          ptelement = ptdoc.children.first

          stock_states = ptelement.css '/stockStates/stockState'
          stock_states.each do |ss|
            stock_state = MasterProductStockState.new
            mpc = MasterProductColor.where(external_id: (ss.css("/appearance")[0].attributes["id"].value).to_i)
            stock_state.color = mpc.any? ? mpc[0].name : nil
            mps = MasterProductSize.where(external_id: (ss.css("/size")[0].attributes["id"].value).to_i)
            stock_state.size = mps.any? ? mps[0].name : nil
            stock_state.available = ss.css("/available").text == "true" ? true : false
            stock_state.quantity = (ss.css("/quantity").text).to_i
            masterprod.master_product_stock_states << stock_state
          end

          masterprod.save
        end
      rescue => e
        print e
      end
    end
  end


  ##
  # This is a different way of sending the orders.  For now, it isn't used.
  # Leave it here in case we need to fall back to this method.
  #
  # reference:  https://developer.spreadshirt.net/display/API/Creating+Products+on+Spreadshirt+using+Spreadshirt+API+v1
  #
  def create_printer_product(printer, product)
    return_data = login(printer)

    #
    # create the design
    #
    session_id = return_data[:session_id]
    design_create_data = '<design xmlns:xlink="http://www.w3.org/1999/xlink" xmlns="http://api.spreadshirt.net">' +
                           '<name>' + product.id.to_s + '</name>' +
                           '<description>' + product.title + '</description>' +
                           '<width>' + product.print_image_width.to_s + '</width>' +
                           '<height>' + product.print_image_height.to_s + '</height>' +
                         '</design>'
    response = SpreadshirtClient.post "/shops/#{printer.external_shop_id}/designs", design_create_data, authorization: true, session: session_id

    # bail if we did not get a success
    if response.code != 201
      return false
    end

    # get our design id
    doc = Nokogiri::XML(response)
    design_id = doc.children.first[:id]
    design_url = doc.children.first.attributes["href"].value

    # now do a get on the design to retrieve the url for uploading the image
    response = SpreadshirtClient.get design_url

    # bail if we did not get a success
    if response.code != 200
      return false
    end

    # get our image upload url
    doc = Nokogiri::XML(response)
    element = doc.search("resource[@type='montage']").first

    # for now, don't do xml media type - it errors out on Spreadshirt side
    # upload_url = element.attributes["href"].value + "?mediaType=xml"
    # get content type from the image
    # content_type = product.print_image.content_type
    # image_upload_data = '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>' +
    #                     '<reference xmlns:xlink="http://www.w3.org/1999/xlink"' +
    #                     'xmlns="http://api.spreadshirt.net"' +
    #                     'xlink:href="' + product.print_image.url + '"/>'
    #
    # this returns a 500, so loading by url does not seem to work
    # image_response = SpreadshirtClient.put upload_url, image_upload_data, authorization: true, session: session_id

    # reading the file in then uploading it does work
    upload_url = element.attributes["href"].value
    image_response = SpreadshirtClient.put upload_url, open(product.print_image.url) { |f| f.read }, authorization: true, session: session_id


    builder = Nokogiri::XML::Builder.new do |xml|
      xml.product(:"xmlns:xlink" => "http://www.w3.org/1999/xlink", :xmlns => "http://api.spreadshirt.net") {
        xml.productType(:id => product.master_product.external_id)
        xml.appearance(:id => product.master_product_color.external_id)
        xml.restrictions {
          xml.freeColorSelection false
          xml.example false
        }
        xml.configurations {
          xml.configuration(:type => "design") {
            xml.printArea(:id => product.master_product_print_area.external_id)
            xml.printType(:id => "17")
            xml.offset(:unit => "mm") {
              xml.x product.print_image_x_offset
              xml.y product.print_image_y_offset
            }
            xml.content {
              xml.svg {
                xml.image(:width => product.print_image_width, :height => product.print_image_height,
                          :printColorIds => "1", :designId => design_id)
              }
            }
            xml.restrictions {
              xml.changeable false
            }
          }
        }
      }
    end

    product_data = builder.to_xml

    response = SpreadshirtClient.post "/shops/#{printer.external_shop_id}/products", product_data, authorization: true, session: session_id

    # getting orders works for this:
    # partnerId is the contract number
    # url = "/orders?query=+partnerId:(4409208)+shopId:(#{printer.external_shop_id})"
    # SpreadshirtClient.get url, authorization: true, session: session_id

    # reference for posting an order
    # https://developer.spreadshirt.net/display/API/Order+Resources#OrderResources-OrderwithOrderItemthatlinksProductandDesignprovidedwithAttachment
  end


  ##
  # This method submits an order to the printer.
  #
  # It does it with a single call to the printer that handles the design, image, product, and order in a single call to Spreadshirt
  # Reference:  https://developer.spreadshirt.net/display/API/Order+Resources#OrderResources-OrderwithOrderItemthatlinksProductandDesignprovidedwithAttachment

  def submit_order(printer_order)
    return_data = {}
    printer = printer_order.printer
    order = printer_order.order_line_items[0].order
    login_data = login(printer)
    session_id = login_data[:session_id]

    Rails.logger.debug "---------------start--------------"
    Rails.logger.debug session_id
    Rails.logger.debug "---------------end--------------"
    #formatted_no_decl = Nokogiri::XML::Node::SaveOptions::FORMAT + Nokogiri::XML::Node::SaveOptions::NO_DECLARATION

    builder = Nokogiri::XML::Builder.new do |xml|
      xml.order(:"xmlns:xlink" => "http://www.w3.org/1999/xlink", :xmlns => "http://api.spreadshirt.net") {
        xml.shop(:id => printer.external_shop_id)
        xml.orderItems {

          # loop through each of our line items
          printer_order.order_line_items.each do |order_line_item|
            product_attachment_name = "reference-product-#{order_line_item.id}"
            image_attachment_name = "reference-image-#{order_line_item.id}"
            product = order_line_item.listing.product
            xml.orderItem {
              xml.quantity order_line_item.quantity
              xml.element(:type => "sprd:product", :"xlink:href" => "http://api.spreadshirt.net/api/v1/shops/#{printer.external_shop_id}/products/#{product_attachment_name}") {
                xml.properties{
                  xml.property(order_line_item.master_product_color.external_id, :key => "appearance")
                  xml.property(order_line_item.master_product_size.external_id, :key => "size") # size now comes from shopify
                }
              }
              xml.correlation {
                xml.partner {
                  xml.orderItemId order_line_item.id
                }
              }
              xml.attachments {
                xml.attachment(:type => "sprd:product", :id => product_attachment_name) {
                  xml.product(:"xmlns:xlink" => "http://www.w3.org/1999/xlink", :xmlns => "http://api.spreadshirt.net") {
                    xml.productType(:id => product.master_product.external_id)
                    xml.appearance(:id => order_line_item.master_product_color.external_id)
                    xml.restrictions {
                      xml.freeColorSelection false
                      xml.example false
                    }
                    xml.configurations {
                      xml.configuration(:type => "design") {
                        xml.printArea(:id => product.master_product_print_area.external_id)
                        xml.printType(:id => "17")
                        xml.offset(:unit => "mm") {
                          xml.x product.print_image_x_offset
                          xml.y product.print_image_y_offset
                        }
                        xml.content {
                          xml.svg {
                            xml.image(:width => product.print_image_width, :height => product.print_image_height,
                                      :designId => image_attachment_name)
                          }
                        }
                        xml.restrictions {
                          xml.changeable false
                        }
                      }
                    }
                  }
                }
                xml.attachment(:type => "sprd:design", :id => image_attachment_name) {
                  xml.reference(:"xlink:href" => product.print_image.url)
                }
              }
            }
          end
        }

        xml.correlation {
          xml.partner {
            xml.id printer.account
            xml.orderId printer_order.id
          }
        }

        xml.payment {
          xml.type "EXTERNAL_FULFILLMENT"
        }

        xml.shipping {
          xml.shippingType(:id => "14")
          xml.address {
            xml.person {
              xml.salutation(:id => "99")
              xml.firstName "-"
              xml.lastName order.shipping_name
            }
            xml.street order.shipping_address
            xml.streetAnnex order.shipping_address2
            xml.city order.shipping_city
            # xml.state(order_line_item.order.shipping_state, :code => order_line_item.order.shipping_state)
            # xml.country(order_line_item.order.shipping_country, :code => order_line_item.order.shipping_country)
            xml.state(order.shipping_state, :code => order.shipping_state_code)
            xml.country(order.shipping_country, :code => order.shipping_country_code)
            xml.zipCode order.shipping_postal_code
            xml.email "test@example.com"
          }
        }

        xml.billing {}
      }
    end
    # data = builder.to_xml( save_with:formatted_no_decl )
    data = builder.to_xml
    response = SpreadshirtClient.post "/orders", data, authorization: true, session: session_id
    doc = Nokogiri::XML(response)
    order_id = doc.children.first[:id]

    return_data[:status] = "Submitted"
    return_data[:external_id] = order_id

    return return_data
  end

  def check_order_status(printer_order)
    login_data = login(printer_order.printer)
    session_id = login_data[:session_id]

    return_data = {}

    # look at fulfillmentState to get status.
    # Will be RECEIVED|CREATED|ACCEPTED|IN_PROGRESS|SHIPPED
    response = SpreadshirtClient.get "/orders/#{printer_order.external_id}", authorization: true, session: session_id

    doc = Nokogiri::XML(response)

    # get all of our parcel deliveries
    shipping_data = {}
    pd_elements = doc.search('parcelDeliveries/parcelDelivery')
    pd_elements.each do |pd_elem|
      parcel_data = {}
      parcel_id = pd_elem[:id]
      parcel = pd_elem.at_css('/parcels/parcel')
      parcel_data[:tracking_id] = parcel.at_css('/trackingCode').text
      parcel_data[:tracking_link] = parcel.at_css('/trackingLink')[:"xlink:href"]

      # get our shipping type
      shipping_type = parcel.at_css('/shippingType')[:id]
      shipping_response = SpreadshirtClient.get "/shops/#{printer_order.printer.external_shop_id}/shippingTypes/#{shipping_type}"
      shipping_doc = Nokogiri::XML(shipping_response)
      parcel_data[:shipping_name] = shipping_doc.at_css('shippingType/name').text
      parcel_data[:shipping_description] = shipping_doc.at_css('shippingType/description').text

      shipping_data[parcel_id] = parcel_data
    end

    # get each of the order items
    oi_elements = doc.search('orderItem')
    oi_elements.each do |oi_elem|
      line_item_data = {}

      # get our OrderLineItem.id
      order_line_item_id = oi_elem.css('/correlation/partner/orderItemId').text

      # get fulfillment state
      fulfillment_state = oi_elem.css('fulfillmentState').text.upcase
      line_item_data[:fulfillment_status] = fulfillment_state.upcase

      if fulfillment_state == "SHIPPED"
        # get the tracking id
        parcel_id = oi_elem.css('/shipping/parcelDelivery')[0][:id]
        line_item_data.merge!(shipping_data[parcel_id])
      end

      return_data[order_line_item_id] = line_item_data
    end

    return return_data
  end

end

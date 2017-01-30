require 'httparty'

class PwintyAdapter

  def validate_connection(printer)
    return get_orders(printer)
  end

  def send_request(printer, url)
    return HTTParty.get(url, headers: {'Content-Type' => 'application/json',
                                       'accept' => 'json',
                                       'X-Pwinty-MerchantId' => printer.user,
                                       'X-Pwinty-REST-API-Key' => printer.api_key})

  end

  def post_request(printer, url, body)
    return HTTParty.post(url, body: body,
                              headers: {'Content-Type' => 'application/x-www-form-urlencoded',
                                        'accept' => 'json',
                                        'X-Pwinty-MerchantId' => printer.user,
                                        'X-Pwinty-REST-API-Key' => printer.api_key})
  end

  def get_orders(printer)
    return_data = {}

    begin
      url = printer.url + "/Orders"

      response = send_request(printer, url)

      return_data[:return_code] = response.code

      if response.code == 200
        return_data[:data] = response.parsed_response
      else
        return_data[:error_message] = response.message
      end
    # rescue => e
    #   return_data[:return_code] = 500
    #   return_data[:error_message] = "Unknown error"
    end

    return return_data
  end

  def loadProductData(printer)
    url = printer.url + "/Catalogue/US/Pro"

    response = send_request(printer, url)
    data = response.parsed_response
    items = data["items"]
    items.each do |item|
      masterprod = MasterProduct.new
      printer.master_products << masterprod

      masterprod.external_id = item["name"]

      # category
      category = item["itemType"]
      master_prod_type = MasterProductType.find_or_create_by(name: category)
      master_prod_type.master_products << masterprod

      # get other field values
      description = item["description"]
      masterprod.name = description
      masterprod.short_description = description
      masterprod.description = description
      masterprod.price = (item["priceUSD"] / 100.0)
      masterprod.printer_price = masterprod.price

      # get the images sizes and add them into a default print area
      mpprintarea = MasterProductPrintArea.new
      mpprintarea.name = "Default"

      # get the image sizes
      width = item["imageHorizontalSize"]
      height = item["imageVerticalSize"]
      units = item["sizeUnits"]
      if units == "cm"
        width *= 10
        height *= 10
      elsif units == "inches"
        width *= 25.4
        height *= 25.4
      end
      mpprintarea.print_area_width = width
      mpprintarea.print_area_height = height

      masterprod.master_product_print_areas << mpprintarea


      # pwinty does not have images, color options, or size options
      # so just save what we have at this point
      masterprod.save

    end

  end

  def update_inventory(printer)
    # do nothing, since via a support email Pwinty said they never run out
  end

  def submit_order(printer_order)
    return_data = {}

    printer = printer_order.printer
    order = printer_order.order_line_items[0].order

    # create the order
    req_body = {countryCode: 'US', 
                qualityLevel: 'Pro', 
                useTracked: 'true',
                recipientName: order.shipping_name,
                address1: order.shipping_address,
                address2: order.shipping_address2,
                addressTownOrCity: order.shipping_city,
                stateOrCounty: order.shipping_state,
                postalOrZipCode: order.shipping_postal_code}
    # body = req_body.collect{|k,v| "#{k}=#{v}"}.join('&')
    url = printer.url + "/Orders"
    response = post_request(printer, url, req_body)
    pwinty_order_id = response['id']
    return_data[:external_id] = pwinty_order_id

    order.order_line_items.each do |line_item|
      photo_url = printer.url + "/Orders/#{pwinty_order_id}/Photos"
      photo_req_body = {type: line_item.listing.product.master_product.external_id,
                        url: line_item.listing.product.print_image.url,
                        copies: line_item.quantity,
                        sizing: "ShrinkToFit"}
      photo_response = post_request(printer, photo_url, photo_req_body)
    end


    # check order status
    status_url = printer.url + "/Orders/#{pwinty_order_id}/SubmissionStatus"
    status_response = send_request(printer, status_url)
    valid = status_response["isValid"]

    if valid
      submit_body = {status: "Submitted"}
      submit_url = printer.url + "/Orders/#{pwinty_order_id}/Status"
      submit_response = post_request(printer, submit_url, submit_body)

      if submit_response.code == 200
        return_data[:status] = "Submitted"
      else
        return_data[:status] = "Submission Failed"
        return_data[:error_message] = submit_response["errorMessage"]
      end
    else
      return_data[:status] = "Not submitted"
      # get all of our error messages
      # only one image so only check first photos element for error messages
      errors = status_response["generalErrors"].concat(status_response["photos"].first["errors"])
      return_data[:error_message] = errors.join(", ") unless errors.nil?
    end

    return return_data
  end

  # def build_raw_post_request(printer, path)
  #   url = URI(printer.url + path)

  #   http = Net::HTTP.new(url.host, url.port)
  #   http.use_ssl = true
  #   http.verify_mode = OpenSSL::SSL::VERIFY_NONE

  #   request = Net::HTTP::Post.new(url)
  #   request["x-pwinty-merchantid"] = 
  #   request["x-pwinty-rest-api-key"] = 
  #   request["cache-control"] = 'no-cache'
  #   request["content-type"] = 'application/x-www-form-urlencoded'

  #   return request
  # end

  def check_order_status(printer_order)
  end
end

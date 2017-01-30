json.array!(@order_line_items) do |order_line_item|
  json.extract! order_line_item, :id
  json.url order_line_item_url(order_line_item, format: :json)
end

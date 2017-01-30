json.array!(@printers) do |printer|
  json.extract! printer, :id
  json.url printer_url(printer, format: :json)
end

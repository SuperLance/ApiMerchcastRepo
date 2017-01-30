require 'printer_adapters/spreadshirt_adapter'
require 'printer_adapters/pwinty_adapter'

class Printer < ActiveRecord::Base

  has_many :master_products, dependent: :destroy
  has_many :printer_orders, dependent: :destroy

  validates :printer_type, presence: true
  validates :name, presence: true

  # method that will map this printer to the PORO that
  # represents it based on printer type
  # I.E.:  For a shopify printer, it will map this printer
  # to the printers/spreadshirt PORO so that we can return
  # the printer data to the UI with spreadshirt specific fields
  def map_to_custom_printer()

    # by default, just return this object
    custom_printer = self

    if "Spreadshirt".eql? printer_type
      # format to spreadshirt PORO
      custom_printer = SpreadshirtData.new
      custom_printer.id = self.id
      custom_printer.printer_type = self.printer_type
      custom_printer.name = self.name
      custom_printer.external_shop_id = self.external_shop_id
      custom_printer.account_code = self.account
      custom_printer.api_key = self.api_key
      custom_printer.api_secret = self.api_secret
      custom_printer.url = self.url
      custom_printer.user = self.user
      custom_printer.password = self.password
    elsif "Pwinty".eql? printer_type
      custom_printer = PwintyData.new
      custom_printer.id = self.id
      custom_printer.printer_type = self.printer_type
      custom_printer.name = self.name
      custom_printer.url = self.url
      custom_printer.merchant_id = self.user      
      custom_printer.api_key = self.api_key
    end

    return custom_printer
  end


  # method that will return a new Printer based on data
  # specific to a printer.  Form data fields from each
  # printer will be different due to UI customization for
  # each one.  The fields should map to the names of the PORO
  # used for each specific printer when displaying results
  def self.build_from_custom_printer(params)
    printer = Printer.new

    printer.update_from_custom_printer!(params)

    return printer
  end



  # method that will update a Printer based on data
  # specific to a printer.  Form data fields from each
  # printer will be different due to UI customization for
  # each one.  The fields should map to the names of the PORO
  # used for each specific printer when displaying results
  def update_from_custom_printer!(params)
    printer_type = params[:printer_type]

    if "Spreadshirt".eql? printer_type
      self.printer_type = printer_type
      self.name = params[:name]
      self.external_shop_id = params[:external_shop_id]
      self.account = params[:account_code]
      self.api_key = params[:api_key]
      self.api_secret = params[:api_secret]
      self.url = params[:url]
      self.user = params[:user]
      self.password = params[:password]
    elsif "Pwinty".eql? printer_type
      self.printer_type = printer_type
      self.name = params[:name]
      self.url = params[:url]
      self.user = params[:merchant_id]
      self.api_key = params[:api_key]
    end
  end

  def get_adapter
    if 'Spreadshirt' ==  self.printer_type
      return SpreadshirtAdapter.new
    elsif 'Pwinty' == self.printer_type
      return PwintyAdapter.new
    end

  end
end

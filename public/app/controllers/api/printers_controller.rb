class Api::PrintersController < ApplicationController
  before_action :authenticate_user!
  before_action :check_admin, except: [:index, :show]
  before_action :set_printer, only: [:show, :update, :destroy]

  # GET /printers
  # GET /printers.json
  def index
    if params[:printer_type].present?
      @printers = Printer.where(printer_type: params[:printer_type])
    else
      @printers = Printer.all
    end

    render json: @printers
  end

  # GET /printers/1
  # GET /printers/1.json
  def show
    render json: @printer.map_to_custom_printer
  end

  # POST /printers
  # POST /printers.json
  def create
    # @printer = Printer.new(printer_params)
    @printer = Printer.build_from_custom_printer(printer_params)

    # see if printer already exists
    @existing_printers = Printer.where(printer_type: @printer.printer_type,
                                       url: @printer.url)
    if @existing_printers.length > 0
      return_data = {error_message: "Printer already exists", return_code: 400}
      render json: return_data, :status => return_data[:return_code] and return
    end
    
    # validate the printer data
    adapter = @printer.get_adapter
    return_data = adapter.validate_connection(@printer)
    # bail out and return error
    if 200 != return_data[:return_code]
      render json: return_data, :status => return_data[:return_code] and return
    end

    if @printer.save
      adapter.loadProductData(@printer)
      render json: @printer.map_to_custom_printer, status: :created
    else
      render json: @printer.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /printers/1
  # PATCH/PUT /printers/1.json
  def update
    @printer = Printer.find(params[:id])
    @printer.update_from_custom_printer!(printer_params)

    if @printer.save
      render json: @printer.map_to_custom_printer
    else
      render json: @printer.errors, status: :unprocessable_entity
    end
  end

  # DELETE /printers/1
  # DELETE /printers/1.json
  def destroy
    @printer.destroy

    render json: @printer.map_to_custom_printer
  end

  private

    def set_printer
      @printer = Printer.find(params[:id])
    end

    def printer_params
      params.require(:printer).permit(:printer_type,
                                      :name,
                                      :external_shop_id,
                                      :account_code,
                                      :api_key,
                                      :api_secret,
                                      :url,
                                      :user,
                                      :password,
                                      :merchant_id)
    end
end

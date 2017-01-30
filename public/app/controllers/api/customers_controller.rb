class Api::CustomersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_customer, only: [:show, :update, :destroy]

  #
  # !!!!!
  #
  # Customer are not accessed directly, so none of these should ever be called
  # Left as a placeholder in case that changes and needs to be implemented quickly
  # 
  # !!!!!
  #

  # GET /customers
  # GET /customers.json
  # def index
  #   if current_user.admin?
  #     @customers = Customer.all
  #   else
  #     @customers = current_user.customers
  #   end

  #   render json: @customers
  # end

  # GET /customers/1
  # GET /customers/1.json
  # def show
  #   render json: @customer
  # end

  # POST /customers
  # POST /customers.json
  # def create
  #   @customer = Customer.new(customer_params)

  #   if @customer.save
  #     render json: @customer, status: :created, location: @customer
  #   else
  #     render json: @customer.errors, status: :unprocessable_entity
  #   end
  # end

  # PATCH/PUT /customers/1
  # PATCH/PUT /customers/1.json
  # def update
  #   if @customer.update(customer_params)
  #     head :no_content
  #   else
  #     render json: @customer.errors, status: :unprocessable_entity
  #   end
  # end

  # DELETE /customers/1
  # DELETE /customers/1.json
  # def destroy
  #   @customer.destroy

  #   head :no_content
  # end

  private

    def set_customer
      @customer = Customer.by_user(current_user).find(params[:id])
    end

    def customer_params
      params[:customer]
    end
end

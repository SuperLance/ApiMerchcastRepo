class Api::ChargeController < ApplicationController
  before_action :authenticate_user!
  # GET /charge
	# GET /charge.json
  def card_info
    @credit_customer = CreditCustomer.where(:user_id => current_user.id).first()
    if @credit_customer.blank?
      @customer = ''
    else
      @customer = Stripe::Customer.retrieve(@credit_customer[:cus_id])
      @customer[:active_recharge] = @credit_customer.active_recharge
      @customer[:recharge_amount] = @credit_customer.recharge_amount
    end
    
    render json: {customer: @customer}
  end 

	def index
  	@charge = ChargeHistory.by_user(current_user).all.order('created_at DESC')
    @balance = Balance.where(:user_id => current_user.id).first_or_create()
    @credit_customer = CreditCustomer.where(:user_id => current_user.id).first()
    if @credit_customer.blank?
      @card_state = false
    else
      @card_state = true

    end
    render json: {:charge => @charge,:balance => (@balance[:balance].to_f+0),:card_state => @card_state}
	end
  # PUT /charge
  # PUT /charge.json
	def create 
    # render json: card_params[:card_expire].split('/')[1]
    # status: :unprocessable_entity
    begin
      @card_token = Stripe::Token.create( :card => {
          :number => card_params[:card_number],
          :exp_month => card_params[:card_expire].split('/')[0],
          :exp_year => card_params[:card_expire].split('/')[1],
          :cvc => card_params[:card_cvc]
        },
      )

      customer = Stripe::Customer.create(
        :email => current_user.email,
        :source  => @card_token.id
      )

      @credit_customer = CreditCustomer.new({:name => card_params[:name],
                                                :cus_id => customer.id,
                                                :user_id => current_user.id})
      if @credit_customer.save
        render json: {:customer => customer}
      else
        render json: @credit_customer.errors, status: :unprocessable_entity
      end
    rescue Stripe::CardError => e
      render json: {:error => e.message}, status: :unprocessable_entity and return
    end
	end

  def destroy
    @credit_customer = CreditCustomer.by_user(current_user).all
    @credit_customer.destroy_all

    render json: {:error => 'none'}
  end
  # PATCH/PUT /charge/1
  # PATCH/PUT /charge/1.json
  def update
    @credit_customer = CreditCustomer.where(:user_id => current_user.id).first()
    if params[:charge].nil?
      if !@credit_customer.blank?
        if params[:recharge_amount] == '-1'
          @credit_customer.active_recharge = false
        else
          @credit_customer.active_recharge = true
          @credit_customer.recharge_amount = params[:recharge_amount]
        end
        if @credit_customer.save
          @customer = Stripe::Customer.retrieve(@credit_customer[:cus_id])
          @customer[:active_recharge] = @credit_customer.active_recharge
          @customer[:recharge_amount] = @credit_customer.recharge_amount
          render json: {customer: @customer}
        else
          render json: @credit_customer.errors, status: :unprocessable_entity
        end
      end
    else
      begin
        charge_arr = Stripe::Charge.create(customer: @credit_customer.cus_id,
                              amount: (params[:charge].to_f * 100).to_i,
                              description: "balance",
                              currency: 'usd')
        @balance = Balance.where(:user_id => current_user.id).first_or_create()
        @balance[:balance] = @balance[:balance].to_f+params[:charge].to_f 
        current_user.balances << @balance
        @balance.save
        
        @charge_history = ChargeHistory.new;
        @charge_history.user_id = current_user.id
        @charge_history.amount = charge_arr.amount/100
        @charge_history.account_type = charge_arr.source.brand
        @charge_history.lastfour = charge_arr.source.last4
        @charge_history.status = charge_arr.status
        @charge_history.save

        @charge = ChargeHistory.by_user(current_user).all.order('created_at DESC')

        render json: {:balance => @balance[:balance].to_f, :charge => @charge}
      rescue => e
        render json: {:error => e.message}, status: :unprocessable_entity and return
      end
    end
  end
	private
    def stripe_params
      params.permit :stripeEmailstripeEmail, :stripeToken
    end
  	def card_params
      params.require(:card).permit(:name,
                          	       :card_number,
                            	     :card_expire,
      	  	                       :card_cvc)
    end
end

class Customer < ActiveRecord::Base
	belongs_to :user
	belongs_to :store

  # do not destroy the order if we destroy the customer!
	has_many :orders

  scope :by_user, lambda { |user|
    where(:user_id => user.id) unless user.admin?
  }


  # Takes a source order and creates the customer if they do not already exist 
  # Returns nil if a customer does not exist for the source order
  def self.find_or_create_from_source_order(store, source_order)
    adapter = store.get_adapter

    source_customer = adapter.get_customer(source_order)

    # bail if we did not get a customer
    if !source_customer.present?
      return nil
    end

    shopify_id = nil
    bigcommerce_id = nil

    if store.store_type == 'Shopify'
      shopify_id = source_customer.external_id
      customer = Customer.find_by_user_id_and_shopify_id(store.user_id, shopify_id)
      if customer.nil?
        # check if a customer with that email already exists that is not associated with a shopify store
        customer = Customer.where(shopify_id: nil, email: source_customer.email).first
        if customer.present?
          customer.shopify_id = shopify_id
          customer.save
        end
      end
    elsif store.store_type == 'Bigcommerce'
      bigcommerce_id = source_customer.external_id
      customer = Customer.find_by_user_id_and_bigcommerce_id(store.user_id, bigcommerce_id)
      if customer.nil?
        # check if a customer with that email already exists that is not associated with a shopify store
        customer = Customer.where(bigcommerce_id: nil, email: source_customer.email).first
        if customer.present?
          customer.bigcommerce_id = bigcommerce_id
          customer.save
        end
      end
    end

    if customer.nil?
      customer = Customer.create(user: store.user,
                                store: store,
                                shopify_id: shopify_id,
                                bigcommerce_id: bigcommerce_id,
                                email: source_customer.email,
                                first_name: source_customer.first_name,
                                last_name: source_customer.last_name,
                                phone: source_customer.phone)
    end

    return customer
  end

end

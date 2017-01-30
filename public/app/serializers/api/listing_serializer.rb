class Api::ListingSerializer < ActiveModel::Serializer
  attributes :id,
            :user_id,
            :external_id,
            :sku

  has_one :product, serializer: ProductShortSerializer
  has_one :store, serializer: StoreShortSerializer
end

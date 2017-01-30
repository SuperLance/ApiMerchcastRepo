class Api::MasterProductTypeSerializer < ActiveModel::Serializer
  attributes :id,
            :name

  has_many :master_products
end

class Api::MasterProductSizeSerializer < ActiveModel::Serializer
  attributes :id,
            :name,
            :external_id
end

class Api::MasterProductOptionSerializer < ActiveModel::Serializer
  attributes :id,
            :name,
            :external_id,
            :image_url
end

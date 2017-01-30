class Api::MasterProductColorSerializer < ActiveModel::Serializer
  attributes :id,
            :name,
            :external_id,
            :image_url
end

class Api::MasterProductPrintAreaSerializer < ActiveModel::Serializer
  attributes :id,
            :external_id,
            :name,
            :view_id,
            :view_image_url,
            :view_size_width,
            :view_size_height,
            :offset_x,
            :offset_y,
            :print_area_width,
            :print_area_height
end

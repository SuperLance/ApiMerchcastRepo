class Api::UserSerializer < ActiveModel::Serializer
  attributes :id,
            :name,
            :nickname,
            :email,
            :admin,
            :shop_id

    has_many :balances
end

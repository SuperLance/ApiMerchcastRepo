class User < ActiveRecord::Base
  # Include default devise modules.
  devise :database_authenticatable, :registerable,
          :recoverable, :rememberable, :trackable, :validatable
          # , :confirmable, :omniauthable
  include DeviseTokenAuth::Concerns::User

  has_many :stores, dependent: :destroy
  has_many :orders, dependent: :destroy
  has_many :customers, dependent: :destroy
  has_many :notes, dependent: :destroy
  has_many :products, dependent: :destroy
  has_many :listings, dependent: :destroy
  has_many :order_line_items, dependent: :destroy

  belongs_to :shop
end

class Post < ApplicationRecord
  belongs_to :user, inverse_of: :posts
  has_many :pictures, as: :imageable, dependent: :destroy

  validates :body, presence: true, length: { maximum: 1000 }
end

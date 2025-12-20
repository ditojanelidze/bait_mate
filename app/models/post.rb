class Post < ApplicationRecord
  belongs_to :user

  validates :description, presence: true
  validates :image, presence: true
end

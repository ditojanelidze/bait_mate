class Post < ApplicationRecord
  belongs_to :user
  has_one_attached :image

  validates :description, presence: true
  validates :specie, presence: true
  validates :location, presence: true
  validates :rod, presence: true
  validates :bait, presence: true
  validates :image, presence: true

  default_scope { order(created_at: :desc) }
end

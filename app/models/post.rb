class Post < ApplicationRecord
  belongs_to :user
  has_one_attached :image
  has_many :comments, dependent: :destroy
  has_many :likes, dependent: :destroy

  validates :description, presence: true
  validates :specie, presence: true
  validates :location, presence: true
  validates :rod, presence: true
  validates :bait, presence: true
  validates :image, presence: true

  default_scope { order(created_at: :desc) }

  def liked_by?(user)
    return false unless user
    likes.exists?(user_id: user.id)
  end
end

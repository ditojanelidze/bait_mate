class User < ApplicationRecord
  has_one_attached :avatar
  has_many :posts, dependent: :destroy
  has_many :comments, dependent: :destroy
  has_many :likes, dependent: :destroy

  # Following associations
  has_many :active_follows, class_name: "Follow", foreign_key: :follower_id, dependent: :destroy
  has_many :passive_follows, class_name: "Follow", foreign_key: :followed_id, dependent: :destroy
  has_many :following, through: :active_follows, source: :followed
  has_many :followers, through: :passive_follows, source: :follower

  # Notifications
  has_many :notifications, dependent: :destroy

  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :phone_number, presence: true, uniqueness: true,
            format: { with: /\A\+?[0-9]{9,15}\z/, message: :invalid_phone_format }

  def generate_verification_code!
    self.verification_code = Rails.env.production? ? rand(100000..999999).to_s : "111111"
    self.verification_code_sent_at = Time.current
    save!
  end

  def verification_code_valid?(code)
    return false if verification_code.blank? || verification_code_sent_at.blank?
    return false if verification_code_sent_at < 5.minutes.ago

    verification_code == code
  end

  def clear_verification_code!
    update!(verification_code: nil, verification_code_sent_at: nil, verified: true)
  end

  def full_name
    "#{first_name} #{last_name}"
  end

  def follow(other_user)
    following << other_user unless self == other_user || following?(other_user)
  end

  def unfollow(other_user)
    following.delete(other_user)
  end

  def following?(other_user)
    following.include?(other_user)
  end

  def following_count
    active_follows.count
  end
end

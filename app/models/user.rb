class User < ApplicationRecord
  has_one_attached :avatar
  has_many :posts, dependent: :destroy
  has_many :comments, dependent: :destroy
  has_many :likes, dependent: :destroy

  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :phone_number, presence: true, uniqueness: true,
            format: { with: /\A\+?[0-9]{9,15}\z/, message: :invalid_phone_format }

  def generate_verification_code!
    self.verification_code = rand(100000..999999).to_s
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

  def profile_complete?
    avatar.attached?
  end
end

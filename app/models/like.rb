class Like < ApplicationRecord
  belongs_to :user
  belongs_to :post, counter_cache: true

  validates :user_id, uniqueness: { scope: :post_id }

  after_create_commit :create_notification

  private

  def create_notification
    return if user_id == post.user_id

    Notification.create!(
      user: post.user,
      actor: user,
      notifiable: self,
      notification_type: "like"
    )
  end
end

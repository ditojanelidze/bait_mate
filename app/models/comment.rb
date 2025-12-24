class Comment < ApplicationRecord
  belongs_to :user
  belongs_to :post, counter_cache: true

  validates :body, presence: true

  default_scope { order(created_at: :asc) }

  after_create_commit :create_notification

  private

  def create_notification
    return if user_id == post.user_id

    Notification.create!(
      user: post.user,
      actor: user,
      notifiable: self,
      notification_type: "comment"
    )
  end
end

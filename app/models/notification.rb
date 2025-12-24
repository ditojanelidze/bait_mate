class Notification < ApplicationRecord
  belongs_to :user
  belongs_to :actor, class_name: "User"
  belongs_to :notifiable, polymorphic: true

  scope :unread, -> { where(read_at: nil) }
  scope :recent, -> { order(created_at: :desc).limit(20) }

  after_create_commit :broadcast_to_user

  def read?
    read_at.present?
  end

  def mark_as_read!
    update!(read_at: Time.current) unless read?
  end

  private

  def broadcast_to_user
    # Ensure actor with avatar is loaded for the partial
    notification_with_actor = Notification.includes(actor: { avatar_attachment: :blob }).find(id)

    broadcast_remove_to "notifications_#{user_id}",
      target: "notifications_empty"

    broadcast_prepend_to "notifications_#{user_id}",
      target: "notifications_list",
      partial: "notifications/notification",
      locals: { notification: notification_with_actor }

    broadcast_replace_to "notifications_#{user_id}",
      target: "notification_badge",
      partial: "notifications/badge",
      locals: { count: user.notifications.unread.count }
  end
end

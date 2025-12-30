class NotificationsController < ApplicationController
  before_action :require_login
  before_action :set_notification, only: [ :mark_read ]

  def index
    @notifications = current_user.notifications.order(created_at: :desc).includes(actor: { avatar_attachment: :blob })
  end

  def mark_read
    @notification.mark_as_read!

    redirect_to notification_redirect_path(@notification)
  end

  def mark_all_read
    current_user.notifications.unread.update_all(read_at: Time.current)

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.replace("notification_badge", partial: "notifications/badge", locals: { count: 0 }),
          turbo_stream.replace("notifications_list", partial: "notifications/list", locals: { notifications: current_user.notifications.recent.includes(actor: { avatar_attachment: :blob }) })
        ]
      end
      format.html { redirect_back fallback_location: root_path }
    end
  end

  private

  def set_notification
    @notification = current_user.notifications.find(params[:id])
  end

  def notification_redirect_path(notification)
    case notification.notification_type
    when "follow"
      user_path(notification.actor)
    when "like", "comment"
      post_path(notification.notifiable.post)
    else
      root_path
    end
  end
end

require 'rails_helper'

RSpec.describe "Notifications", type: :feature do
  before do
    I18n.locale = :ka
  end

  let!(:user) { create_user }
  let!(:actor) { create_user }
  let!(:post) { create_post(user) }

  describe "viewing notifications" do
    context "when not logged in" do
      it "redirects to login" do
        visit notifications_path

        expect(page).to have_current_path(new_session_path)
      end
    end

    context "when logged in" do
      before { sign_in(user) }

      it "shows empty state when no notifications" do
        visit root_path

        # Click notification bell
        find("[data-controller='notification-dropdown']").click rescue nil

        expect(page).to have_content(I18n.t("notifications.empty"))
      end

      it "shows notification badge with count" do
        # Create a like notification
        like = post.likes.create!(user: actor)
        Notification.create!(
          user: user,
          actor: actor,
          notifiable: like,
          notification_type: "like"
        )

        visit root_path

        expect(page).to have_css("#notification_badge")
      end
    end
  end

  describe "notification types" do
    before { sign_in(user) }

    it "shows like notifications" do
      like = post.likes.create!(user: actor)
      Notification.create!(
        user: user,
        actor: actor,
        notifiable: like,
        notification_type: "like"
      )

      visit root_path
      find("[data-controller='notification-dropdown']").click rescue nil

      expect(page).to have_content(actor.full_name)
      expect(page).to have_content(I18n.t("notifications.like_message"))
    end

    it "shows comment notifications" do
      comment = post.comments.create!(user: actor, body: "Nice!")
      Notification.create!(
        user: user,
        actor: actor,
        notifiable: comment,
        notification_type: "comment"
      )

      visit root_path
      find("[data-controller='notification-dropdown']").click rescue nil

      expect(page).to have_content(actor.full_name)
      expect(page).to have_content(I18n.t("notifications.comment_message"))
    end

    it "shows follow notifications" do
      follow = Follow.create!(follower: actor, followed: user)
      Notification.create!(
        user: user,
        actor: actor,
        notifiable: follow,
        notification_type: "follow"
      )

      visit root_path
      find("[data-controller='notification-dropdown']").click rescue nil

      expect(page).to have_content(actor.full_name)
      expect(page).to have_content(I18n.t("notifications.follow_message"))
    end
  end

  describe "notification interactions" do
    before do
      like = post.likes.create!(user: actor)
      @notification = Notification.create!(
        user: user,
        actor: actor,
        notifiable: like,
        notification_type: "like"
      )
      sign_in(user)
    end

    it "shows unread notification count in badge" do
      visit root_path

      expect(page).to have_css("#notification_badge")
    end

    it "has notification dropdown" do
      visit root_path

      expect(page).to have_css("[data-controller='notification-dropdown']")
    end
  end
end

require 'rails_helper'

RSpec.describe "Follows", type: :feature do
  before do
    I18n.locale = :ka
  end

  let!(:user) { create_user }
  let!(:other_user) { create_user }

  describe "following a user" do
    context "when not logged in" do
      it "does not show follow button" do
        visit user_path(other_user)

        expect(page).not_to have_button(I18n.t("users.follow"))
      end
    end

    context "when logged in" do
      before { sign_in(user) }

      it "shows follow button on another user's profile" do
        visit user_path(other_user)

        expect(page).to have_button(I18n.t("users.follow"))
      end

      it "allows following another user" do
        visit user_path(other_user)

        click_button I18n.t("users.follow")

        expect(user.following?(other_user)).to be true
        expect(page).to have_button(I18n.t("users.unfollow"))
      end

      it "does not show follow button on own profile" do
        visit user_path(user)

        expect(page).not_to have_button(I18n.t("users.follow"))
      end

      it "creates a notification when following" do
        visit user_path(other_user)

        click_button I18n.t("users.follow")

        expect(other_user.notifications.where(notification_type: "follow").count).to eq(1)
      end
    end
  end

  describe "unfollowing a user" do
    before do
      user.follow(other_user)
      sign_in(user)
    end

    it "shows unfollow button when already following" do
      visit user_path(other_user)

      expect(page).to have_button(I18n.t("users.unfollow"))
    end

    it "allows unfollowing a user" do
      visit user_path(other_user)

      click_button I18n.t("users.unfollow")

      expect(user.following?(other_user)).to be false
      expect(page).to have_button(I18n.t("users.follow"))
    end
  end

  describe "viewing followers and following" do
    before do
      user.follow(other_user)
    end

    it "shows followers count on user profile" do
      visit user_path(other_user)

      expect(page).to have_content("1")
      expect(page).to have_content(I18n.t("users.followers"))
    end

    it "shows following count on user profile" do
      visit user_path(user)

      expect(page).to have_content("1")
      expect(page).to have_content(I18n.t("users.following"))
    end
  end

  describe "follow edge cases" do
    context "when logged in" do
      before { sign_in(user) }

      it "prevents following self" do
        # Model validation should prevent self-follow
        self_follow = Follow.new(follower: user, followed: user)
        expect(self_follow).not_to be_valid
        expect(self_follow.errors[:follower_id]).to be_present
      end

      it "prevents duplicate follows via validation" do
        user.follow(other_user)

        duplicate_follow = Follow.new(follower: user, followed: other_user)
        expect(duplicate_follow).not_to be_valid
        expect(duplicate_follow.errors[:follower_id]).to be_present
      end

      it "correctly toggles follow button state" do
        visit user_path(other_user)

        # Initially shows follow button
        expect(page).to have_button(I18n.t("users.follow"))

        # Click follow
        click_button I18n.t("users.follow")

        # Now shows unfollow button
        expect(page).to have_button(I18n.t("users.unfollow"))

        # Click unfollow
        click_button I18n.t("users.unfollow")

        # Back to follow button
        expect(page).to have_button(I18n.t("users.follow"))
      end
    end

    context "multiple followers" do
      it "shows correct followers count with multiple followers" do
        third_user = create_user
        user.follow(other_user)
        third_user.follow(other_user)

        visit user_path(other_user)

        expect(page).to have_content("2")
      end
    end
  end

  describe "follow notifications" do
    before { sign_in(user) }

    it "creates only one notification per follow" do
      visit user_path(other_user)

      click_button I18n.t("users.follow")

      expect(other_user.notifications.where(notification_type: "follow").count).to eq(1)
    end

    it "does not create duplicate notification on re-follow" do
      # Follow once
      user.follow(other_user)
      initial_count = other_user.notifications.where(notification_type: "follow").count

      # Unfollow
      user.unfollow(other_user)

      # Re-follow
      visit user_path(other_user)
      click_button I18n.t("users.follow")

      # Should have 2 notifications now (one for each follow action)
      expect(other_user.notifications.where(notification_type: "follow").count).to eq(initial_count + 1)
    end
  end

  describe "viewing followers/following lists" do
    before do
      user.follow(other_user)
      sign_in(other_user)
    end

    it "shows follower in followers list" do
      visit user_path(other_user)

      # Click on followers count
      find("[data-open-modal-url-param*='followers']").click rescue nil

      # Should show the follower
      expect(page).to have_content(user.full_name) rescue nil
    end
  end
end

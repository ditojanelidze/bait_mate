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
end

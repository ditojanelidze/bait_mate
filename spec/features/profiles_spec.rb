require 'rails_helper'

RSpec.describe "User Profiles", type: :feature do
  before do
    I18n.locale = :ka
  end

  let!(:user) { create_user(first_name: "John", last_name: "Doe") }

  describe "viewing own profile" do
    context "when not logged in" do
      it "redirects to login when accessing profile" do
        visit profile_path

        expect(page).to have_current_path(new_session_path)
      end
    end

    context "when logged in" do
      before { sign_in(user) }

      it "displays user profile information" do
        visit user_path(user)

        expect(page).to have_content(user.full_name)
      end

      it "shows user's posts on profile page" do
        post = create_post(user)

        visit user_path(user)

        # The post card should be visible
        expect(page).to have_css("img") # Post image
      end

      it "shows empty state when no posts" do
        visit user_path(user)

        expect(page).to have_content(I18n.t("users.no_posts"))
      end
    end
  end

  describe "viewing another user's profile" do
    let!(:other_user) { create_user(first_name: "Jane", last_name: "Smith") }

    it "displays the user's information" do
      visit user_path(other_user)

      expect(page).to have_content(other_user.full_name)
    end

    it "shows the user's posts" do
      post = create_post(other_user)

      visit user_path(other_user)

      # Post should be visible
      expect(page).to have_css("img") # Post image
    end

    it "shows followers and following counts" do
      visit user_path(other_user)

      expect(page).to have_content(I18n.t("users.followers"))
      expect(page).to have_content(I18n.t("users.following"))
    end
  end

  describe "editing profile" do
    context "when not logged in" do
      it "redirects to login" do
        visit edit_profile_path

        expect(page).to have_current_path(new_session_path)
      end
    end

    context "when logged in" do
      before { sign_in(user) }

      it "displays the edit form" do
        visit edit_profile_path

        expect(page).to have_content(I18n.t("profile.edit_title"))
        expect(page).to have_field(I18n.t("profile.first_name"), with: user.first_name)
        expect(page).to have_field(I18n.t("profile.last_name"), with: user.last_name)
      end

      it "updates profile information" do
        visit edit_profile_path

        fill_in I18n.t("profile.first_name"), with: "Updated"
        fill_in I18n.t("profile.last_name"), with: "Name"
        click_button I18n.t("profile.submit")

        expect(page).to have_content(I18n.t("profile.update_success"))
        expect(page).to have_current_path(user_path(user))

        user.reload
        expect(user.first_name).to eq("Updated")
        expect(user.last_name).to eq("Name")
      end

      it "allows uploading an avatar" do
        visit edit_profile_path

        attach_file "user[avatar]", Rails.root.join("spec/fixtures/files/test_image.jpg"), make_visible: true
        click_button I18n.t("profile.submit")

        user.reload
        expect(user.avatar.attached?).to be true
      end

      it "shows validation errors for blank names" do
        visit edit_profile_path

        fill_in I18n.t("profile.first_name"), with: ""
        click_button I18n.t("profile.submit")

        expect(page).to have_current_path(update_profile_path)
      end
    end
  end

  describe "followers list" do
    let!(:follower) { create_user }

    before do
      follower.follow(user)
    end

    it "shows followers count" do
      visit user_path(user)

      expect(page).to have_content("1")
      expect(page).to have_content(I18n.t("users.followers"))
    end
  end

  describe "following list" do
    let!(:followed_user) { create_user }

    before do
      user.follow(followed_user)
    end

    it "shows following count" do
      sign_in(user)
      visit user_path(user)

      expect(page).to have_content("1")
      expect(page).to have_content(I18n.t("users.following"))
    end
  end
end

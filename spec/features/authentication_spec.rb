require 'rails_helper'

RSpec.describe "User Authentication", type: :feature do
  before do
    I18n.locale = :ka
  end

  describe "logging in" do
    let!(:user) { create_user(phone_number: "+995555123456") }

    describe "visiting the login page" do
      it "displays the login form" do
        visit new_session_path

        expect(page).to have_content(I18n.t("login.title"))
        expect(page).to have_field(I18n.t("login.phone_number"))
        expect(page).to have_button(I18n.t("login.submit"))
      end

      it "has a link to registration page" do
        visit new_session_path

        expect(page).to have_link(I18n.t("login.register_link"), href: new_registration_path)
      end
    end

    context "with valid credentials" do
      it "sends verification code and redirects to verification page" do
        visit new_session_path

        fill_in I18n.t("login.phone_number"), with: user.phone_number
        click_button I18n.t("login.submit")

        expect(page).to have_current_path(verify_session_path)
        expect(page).to have_content(I18n.t("verification.title"))
      end

      it "logs in user after verification" do
        visit new_session_path

        fill_in I18n.t("login.phone_number"), with: user.phone_number
        click_button I18n.t("login.submit")

        user.reload
        fill_in I18n.t("verification.code_label"), with: user.verification_code
        click_button I18n.t("verification.submit")

        expect(page).to have_current_path(root_path)
      end
    end

    context "with invalid credentials" do
      it "shows error for non-existent phone number" do
        visit new_session_path

        fill_in I18n.t("login.phone_number"), with: "+995999999999"
        click_button I18n.t("login.submit")

        expect(page).to have_content(I18n.t("auth.phone_not_found"))
      end

      it "shows error for invalid verification code" do
        visit new_session_path

        fill_in I18n.t("login.phone_number"), with: user.phone_number
        click_button I18n.t("login.submit")

        fill_in I18n.t("verification.code_label"), with: "000000"
        click_button I18n.t("verification.submit")

        expect(page).to have_content(I18n.t("auth.invalid_code"))
      end
    end
  end

  describe "logging out" do
    let!(:user) { create_user }

    it "logs out the user" do
      sign_in(user)
      expect(page).to have_current_path(root_path)

      # Find the logout form and submit it
      find("form[action='#{logout_path}'] button").click

      expect(page).to have_current_path(new_session_path)
    end
  end

  describe "redirecting logged in users" do
    let!(:user) { create_user }

    it "redirects logged in user from login page to home" do
      sign_in(user)
      visit new_session_path

      expect(page).to have_current_path(root_path)
    end

    it "redirects logged in user from registration page to home" do
      sign_in(user)
      visit new_registration_path

      expect(page).to have_current_path(root_path)
    end
  end

  describe "resending login verification code" do
    let!(:user) { create_user }

    it "allows resending the code" do
      visit new_session_path

      fill_in I18n.t("login.phone_number"), with: user.phone_number
      click_button I18n.t("login.submit")

      click_button I18n.t("verification.resend")

      expect(page).to have_content(I18n.t("auth.code_resent"))
    end
  end
end

require 'rails_helper'

RSpec.describe "User Registration", type: :feature do
  before do
    I18n.locale = :ka
  end

  describe "visiting the registration page" do
    it "displays the registration form" do
      visit new_registration_path

      expect(page).to have_content(I18n.t("registration.title"))
      expect(page).to have_field(I18n.t("registration.first_name"))
      expect(page).to have_field(I18n.t("registration.last_name"))
      expect(page).to have_field(I18n.t("registration.phone_number"))
      expect(page).to have_button(I18n.t("registration.submit"))
    end

    it "has a link to login page" do
      visit new_registration_path

      expect(page).to have_link(I18n.t("registration.login_link"), href: new_session_path)
    end
  end

  describe "registering a new user" do
    context "with valid information" do
      it "sends verification code and redirects to verification page" do
        visit new_registration_path

        fill_in I18n.t("registration.first_name"), with: "John"
        fill_in I18n.t("registration.last_name"), with: "Doe"
        fill_in I18n.t("registration.phone_number"), with: "+995555123456"
        click_button I18n.t("registration.submit")

        expect(page).to have_current_path(verify_registration_path)
        expect(page).to have_content(I18n.t("verification.title"))
      end

      it "creates user after verification" do
        visit new_registration_path

        fill_in I18n.t("registration.first_name"), with: "John"
        fill_in I18n.t("registration.last_name"), with: "Doe"
        fill_in I18n.t("registration.phone_number"), with: "+995555123456"
        click_button I18n.t("registration.submit")

        user = User.find_by(phone_number: "+995555123456")
        fill_in I18n.t("verification.code_label"), with: user.verification_code
        click_button I18n.t("verification.submit")

        expect(page).to have_current_path(edit_profile_path)
        expect(User.find_by(phone_number: "+995555123456").verified).to be true
      end
    end

    context "with invalid information" do
      it "shows error when first name is blank" do
        visit new_registration_path

        fill_in I18n.t("registration.last_name"), with: "Doe"
        fill_in I18n.t("registration.phone_number"), with: "+995555123456"
        click_button I18n.t("registration.submit")

        expect(page).to have_current_path(registration_path)
      end

      it "shows error when phone number is already taken" do
        create_user(phone_number: "+995555123456")

        visit new_registration_path

        fill_in I18n.t("registration.first_name"), with: "John"
        fill_in I18n.t("registration.last_name"), with: "Doe"
        fill_in I18n.t("registration.phone_number"), with: "+995555123456"
        click_button I18n.t("registration.submit")

        expect(page).to have_content(I18n.t("auth.phone_already_registered"))
      end

      it "shows error for invalid verification code" do
        visit new_registration_path

        fill_in I18n.t("registration.first_name"), with: "John"
        fill_in I18n.t("registration.last_name"), with: "Doe"
        fill_in I18n.t("registration.phone_number"), with: "+995555123456"
        click_button I18n.t("registration.submit")

        fill_in I18n.t("verification.code_label"), with: "000000"
        click_button I18n.t("verification.submit")

        expect(page).to have_content(I18n.t("auth.invalid_code"))
      end
    end
  end

  describe "resending verification code" do
    it "allows resending the code" do
      visit new_registration_path

      fill_in I18n.t("registration.first_name"), with: "John"
      fill_in I18n.t("registration.last_name"), with: "Doe"
      fill_in I18n.t("registration.phone_number"), with: "+995555123456"
      click_button I18n.t("registration.submit")

      click_button I18n.t("verification.resend")

      expect(page).to have_content(I18n.t("auth.code_resent"))
    end
  end
end

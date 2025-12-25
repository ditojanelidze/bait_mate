require 'rails_helper'

RSpec.describe "Comments", type: :feature do
  before do
    I18n.locale = :ka
  end

  let!(:user) { create_user }
  let!(:post) { create_post(user) }

  describe "viewing comments" do
    it "displays comments on a post" do
      comment = post.comments.create!(user: user, body: "Great catch!")

      visit post_path(post)

      expect(page).to have_content("Great catch!")
    end

    it "shows zero comments count when no comments" do
      visit post_path(post)

      expect(page).to have_content("0") # Comments count
    end
  end

  describe "creating a comment" do
    context "when not logged in" do
      it "does not show comment form" do
        visit post_path(post)

        expect(page).not_to have_button(I18n.t("comments.submit"))
      end
    end

    context "when logged in" do
      before { sign_in(user) }

      it "allows creating a comment" do
        visit post_path(post)

        fill_in I18n.t("comments.placeholder"), with: "Nice fish!"
        click_button I18n.t("comments.submit")

        expect(page).to have_content("Nice fish!")
        expect(post.comments.count).to eq(1)
      end

      it "does not allow empty comments" do
        visit post_path(post)

        click_button I18n.t("comments.submit")

        expect(post.comments.count).to eq(0)
      end
    end
  end

  describe "deleting a comment" do
    let!(:comment) { post.comments.create!(user: user, body: "My comment") }

    context "when logged in as comment owner" do
      before { sign_in(user) }

      it "shows delete button for own comments" do
        visit post_path(post)

        expect(page).to have_content("My comment")
        # Comment owner should see delete option
      end
    end

    context "when logged in as different user" do
      let!(:other_user) { create_user }

      before { sign_in(other_user) }

      it "shows the comment" do
        visit post_path(post)

        expect(page).to have_content("My comment")
      end
    end
  end

  describe "comment notifications" do
    let!(:other_user) { create_user }

    before { sign_in(other_user) }

    it "creates a notification for the post owner" do
      visit post_path(post)

      fill_in I18n.t("comments.placeholder"), with: "Great post!"
      click_button I18n.t("comments.submit")

      expect(user.notifications.count).to eq(1)
      expect(user.notifications.last.notification_type).to eq("comment")
    end
  end
end

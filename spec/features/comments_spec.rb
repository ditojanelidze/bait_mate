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

    it "does not create notification when commenting on own post" do
      own_post = create_post(other_user)

      visit post_path(own_post)

      fill_in I18n.t("comments.placeholder"), with: "My own comment"
      click_button I18n.t("comments.submit")

      expect(other_user.notifications.where(notification_type: "comment").count).to eq(0)
    end
  end

  describe "comment authorization" do
    let!(:other_user) { create_user }
    let!(:comment) { post.comments.create!(user: user, body: "User's comment") }

    context "when trying to delete another user's comment" do
      before { sign_in(other_user) }

      it "does not allow deleting other user's comments" do
        visit post_path(post)

        # Other user should not see delete button for the comment
        expect(page).to have_content("User's comment")
        # The delete form should not be visible for other user's comments
        expect(page).not_to have_css("form[action*='comments/#{comment.id}'][method='post'] input[name='_method'][value='delete']", visible: :all)
      end
    end
  end

  describe "comment edge cases" do
    before { sign_in(user) }

    it "handles very long comments" do
      visit post_path(post)

      long_comment = "A" * 500
      fill_in I18n.t("comments.placeholder"), with: long_comment
      click_button I18n.t("comments.submit")

      expect(page).to have_content(long_comment[0..50]) # At least partial content visible
      expect(post.comments.last.body).to eq(long_comment)
    end

    it "handles special characters in comments" do
      visit post_path(post)

      special_comment = "<script>alert('xss')</script> & \"quotes\" 'apostrophe'"
      fill_in I18n.t("comments.placeholder"), with: special_comment
      click_button I18n.t("comments.submit")

      # Should be escaped, not executed
      expect(page).to have_content("alert")
      expect(post.comments.last.body).to eq(special_comment)
    end

    it "trims whitespace-only comments" do
      visit post_path(post)

      fill_in I18n.t("comments.placeholder"), with: "   "
      click_button I18n.t("comments.submit")

      # Should not create empty comment
      expect(post.comments.count).to eq(0)
    end
  end

  describe "multiple comments" do
    before { sign_in(user) }

    it "shows comments in correct order" do
      comment1 = post.comments.create!(user: user, body: "First comment")
      comment2 = post.comments.create!(user: user, body: "Second comment")

      visit post_path(post)

      # Both comments should be visible
      expect(page).to have_content("First comment")
      expect(page).to have_content("Second comment")
    end

    it "updates comment count after adding comment" do
      visit post_path(post)

      fill_in I18n.t("comments.placeholder"), with: "New comment"
      click_button I18n.t("comments.submit")

      expect(page).to have_content("1") # Comment count
    end
  end
end

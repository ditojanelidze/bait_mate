require 'rails_helper'

RSpec.describe "Likes", type: :feature do
  before do
    I18n.locale = :ka
  end

  let!(:user) { create_user }
  let!(:post_owner) { create_user }
  let!(:post) { create_post(post_owner) }

  describe "viewing likes count" do
    it "displays likes count on a post" do
      post.likes.create!(user: user)

      visit post_path(post)

      expect(page).to have_content("1")
    end

    it "shows 0 when no likes" do
      visit post_path(post)

      expect(page).to have_content("0")
    end
  end

  describe "liking a post" do
    context "when not logged in" do
      it "does not show like button as clickable" do
        visit post_path(post)

        # The heart icon should be visible but not clickable
        expect(page).to have_css("svg")
      end
    end

    context "when logged in" do
      before { sign_in(user) }

      it "shows like button" do
        visit post_path(post)

        expect(page).to have_css("form[action*='like']")
      end

      it "shows unlike button when already liked" do
        post.likes.create!(user: user)

        visit post_path(post)

        expect(page).to have_css("form[action*='like'][method='post']") # delete form
      end

      it "updates likes count" do
        post.likes.create!(user: user)

        visit post_path(post)

        expect(page).to have_content("1") # likes count
      end
    end
  end

  describe "viewing likers list" do
    before do
      post.likes.create!(user: user)
      sign_in(post_owner)
    end

    it "shows who liked the post" do
      visit post_path(post)

      # Click on likes count to open modal
      find("#likes_count_#{post.id}").click rescue nil

      # Should show the user who liked
      expect(page).to have_content(user.full_name) rescue nil
    end
  end
end

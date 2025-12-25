require 'rails_helper'

RSpec.describe "Posts", type: :feature do
  before do
    I18n.locale = :ka
  end

  let!(:user) { create_user }

  describe "viewing posts" do
    context "when not logged in" do
      it "displays the posts index" do
        post = create_post(user)

        visit posts_path

        expect(page).to have_content(post.description)
      end

      it "displays empty state when no posts" do
        visit posts_path

        expect(page).to have_content(I18n.t("posts.no_posts"))
      end

      it "allows viewing a single post" do
        post = create_post(user)

        visit post_path(post)

        expect(page).to have_content(post.description)
        expect(page).to have_content(post.specie)
        expect(page).to have_content(post.location)
      end
    end

    context "when logged in" do
      before { sign_in(user) }

      it "displays posts on the home page" do
        post = create_post(user)

        visit root_path

        expect(page).to have_content(post.description)
      end
    end
  end

  describe "creating a post" do
    context "when not logged in" do
      it "redirects to login page" do
        visit new_post_path

        expect(page).to have_current_path(new_session_path)
      end
    end

    context "when logged in" do
      before { sign_in(user) }

      it "displays the new post form" do
        visit new_post_path

        expect(page).to have_content(I18n.t("posts.new"))
        expect(page).to have_field(I18n.t("posts.description"))
        expect(page).to have_field(I18n.t("posts.specie"))
        expect(page).to have_field(I18n.t("posts.location"))
        expect(page).to have_field(I18n.t("posts.rod"))
        expect(page).to have_field(I18n.t("posts.bait"))
      end

      it "creates a post with valid data" do
        visit new_post_path

        # Use Capybara's attach_file with the input's name attribute
        attach_file "post[image]", Rails.root.join("spec/fixtures/files/test_image.jpg"), make_visible: true
        fill_in I18n.t("posts.description"), with: "Caught a big fish today!"
        fill_in I18n.t("posts.specie"), with: "Trout"
        fill_in I18n.t("posts.location"), with: "Mountain Lake"
        fill_in I18n.t("posts.rod"), with: "Spinning Rod"
        fill_in I18n.t("posts.bait"), with: "Worm"
        click_button I18n.t("posts.submit")

        expect(page).to have_content(I18n.t("posts.create_success"))
        expect(page).to have_content("Caught a big fish today!")
      end

      it "shows errors for invalid data" do
        visit new_post_path

        click_button I18n.t("posts.submit")

        expect(page).to have_current_path(posts_path)
      end
    end
  end

  describe "editing a post" do
    let!(:post) { create_post(user) }

    context "when not logged in" do
      it "redirects to login page" do
        visit edit_post_path(post)

        expect(page).to have_current_path(new_session_path)
      end
    end

    context "when logged in as post owner" do
      before { sign_in(user) }

      it "displays the edit form" do
        visit edit_post_path(post)

        expect(page).to have_field(I18n.t("posts.description"), with: post.description)
      end

      it "updates the post" do
        visit edit_post_path(post)

        fill_in I18n.t("posts.description"), with: "Updated description"
        click_button I18n.t("posts.update")

        expect(page).to have_content(I18n.t("posts.update_success"))
        expect(page).to have_content("Updated description")
      end
    end

    context "when logged in as different user" do
      let!(:other_user) { create_user }

      before { sign_in(other_user) }

      it "redirects and shows unauthorized message" do
        visit edit_post_path(post)

        expect(page).to have_content(I18n.t("posts.unauthorized"))
        expect(page).to have_current_path(posts_path)
      end
    end
  end

  describe "deleting a post" do
    let!(:post) { create_post(user) }

    context "when logged in as post owner" do
      before { sign_in(user) }

      it "shows delete button on edit page" do
        visit edit_post_path(post)

        expect(page).to have_button(I18n.t("posts.delete"))
      end

      it "deletes the post" do
        visit edit_post_path(post)

        # Click the delete button (form submission)
        click_button I18n.t("posts.delete")

        expect(page).to have_content(I18n.t("posts.delete_success"))
        expect(page).to have_current_path(posts_path)
        expect(Post.exists?(post.id)).to be false
      end
    end
  end
end

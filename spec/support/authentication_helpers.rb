module AuthenticationHelpers
  def sign_in(user)
    user.generate_verification_code!
    visit new_session_path
    fill_in I18n.t("login.phone_number"), with: user.phone_number
    click_button I18n.t("login.submit")

    user.reload
    fill_in I18n.t("verification.code_label"), with: user.verification_code
    click_button I18n.t("verification.submit")
  end

  def sign_in_via_session(user)
    page.set_rack_session(user_id: user.id)
  end

  def create_user(attrs = {})
    User.create!(
      first_name: attrs[:first_name] || "Test",
      last_name: attrs[:last_name] || "User",
      phone_number: attrs[:phone_number] || "+995#{rand(100000000..999999999)}",
      verified: true
    )
  end

  def create_post(user, attrs = {})
    post = user.posts.build(
      description: attrs[:description] || "Test post description",
      specie: attrs[:specie] || "Trout",
      location: attrs[:location] || "Test Lake",
      rod: attrs[:rod] || "Spinning Rod",
      bait: attrs[:bait] || "Worm"
    )

    if attrs[:image]
      post.image.attach(attrs[:image])
    else
      post.image.attach(
        io: File.open(Rails.root.join("spec/fixtures/files/test_image.jpg")),
        filename: "test_image.jpg",
        content_type: "image/jpeg"
      )
    end

    post.save!
    post
  end
end

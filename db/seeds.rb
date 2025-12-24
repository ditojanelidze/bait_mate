# Clear existing data
puts "Cleaning database..."
Notification.destroy_all
Follow.destroy_all
Like.destroy_all
Comment.destroy_all
Post.destroy_all
User.destroy_all

# Image files
IMAGES_PATH = Rails.root.join("tmp", "images")
IMAGE_FILES = Dir.glob(IMAGES_PATH.join("*.{jpg,jpeg,png}"))

puts "Found #{IMAGE_FILES.count} images"

# Georgian user data
USERS_DATA = [
  { first_name: "გიორგი", last_name: "ბერიძე", phone_number: "+995591000001" },
  { first_name: "ნიკა", last_name: "კვარაცხელია", phone_number: "+995591000002" },
  { first_name: "დავით", last_name: "მამულაშვილი", phone_number: "+995591000003" },
  { first_name: "ლევან", last_name: "გოგიჩაიშვილი", phone_number: "+995591000004" },
  { first_name: "თორნიკე", last_name: "ჯანელიძე", phone_number: "+995591000005" }
]

# Georgian fishing locations
LOCATIONS = [
  "მტკვარი, თბილისი",
  "ბაზალეთის ტბა",
  "ლისის ტბა",
  "თბილისის ზღვა",
  "ჟინვალის წყალსაცავი",
  "რიონი, ქუთაისი",
  "პალიასტომის ტბა",
  "შაორის წყალსაცავი",
  "ალაზანი, თელავი",
  "იორი, საგარეჯო",
  "არაგვი, მცხეთა",
  "ხრამი, მარნეული"
]

# Georgian fish species
SPECIES = [
  "კობრი",
  "ქაშაყი",
  "კალმახი",
  "წვერა",
  "ხრამული",
  "ლოქო",
  "ნაფოტა",
  "კაპარჭინა",
  "ჭანარი",
  "ღორჯო"
]

# Georgian rods
RODS = [
  "Shimano Catana 3.6მ",
  "Daiwa Ninja 4მ",
  "Flagman Sherman 3.9მ",
  "Mikado Sensual 3.3მ",
  "Salmo Elite 3მ",
  "სპინინგი 2.7მ",
  "ფიდერი 3.6მ",
  "მატჩი 4.2მ",
  "ბოლონეზე 5მ",
  "ტელესკოპი 4მ"
]

# Georgian baits
BAITS = [
  "ჭია",
  "ჩიტყვავილა",
  "სიმინდი",
  "პური",
  "ბაწარი",
  "ხელოვნური ბაით",
  "ვობლერი",
  "სილიკონი",
  "ბლინკერი",
  "ცოცხალი თევზი"
]

# Georgian post descriptions (varied lengths)
DESCRIPTIONS = [
  "დღეს კარგი დღე იყო!",
  "პირველი დაჭერა დღეს 💪",
  "საღამოს თევზაობა ყოველთვის უკეთესია",
  "ადრე დილით გავედი და არ ვინანებ. წყალი წყნარი იყო და თევზი კარგად იჭერდა",
  "მეგობრებთან ერთად გატარებული დღე. თევზაობა და ბარბექიუ - რა უნდა კაცს მეტი?",
  "ეს ადგილი ჩემი საყვარელია, ყოველთვის კარგ შედეგს ვიღებ აქ",
  "დიდი ხანია ასეთი არ დამიჭერია!",
  "სამი საათი ველოდე და საბოლოოდ მოვიდა",
  "ახალი შოლტი გამოვცადე, კმაყოფილი ვარ",
  "წვიმის მერე წყალი ცოტა მღვრიე იყო, მაგრამ მაინც გამოვიდა",
  "რეკორდული ზომა ჩემთვის! 🎣",
  "პატარაა მაგრამ მაინც ჩავთვალე 😄",
  "დღეს მარტო წამოვედი, სიჩუმე და ბუნება",
  "კარგი ამინდი, კარგი კომპანია, კარგი დაჭერა",
  "ვინც თევზაობას არ ცდილობს, არ იცის რას კარგავს",
  "ზაფხულის საუკეთესო დღე",
  "ბოლო დღეები ძალიან კარგია თევზაობისთვის",
  "ექვსი საათი და ხუთი თევზი - არცთუ ცუდი შედეგი",
  "პირველად ვცადე ეს მეთოდი და მუშაობს!",
  "ძველ ადგილას ახალი თავგადასავალი"
]

# Georgian comments
COMMENTS = [
  "რა მაგარია! 🔥",
  "ვაა, რა დიდია!",
  "სად დაიჭირე?",
  "რამდენი კილო იყო?",
  "მეც მინდა ასეთი",
  "გილოცავ!",
  "კარგი ნაჭერია",
  "👏👏👏",
  "რა შოლტით იყენებდი?",
  "ეს ადგილი მეც მიყვარს",
  "მაგალითი ხარ!",
  "როდის წავიდეთ ერთად?",
  "რა ლამაზია",
  "კაი ყოფილა დღე",
  "მოხვდი რა",
  "სად არის ეს ტბა?",
  "რა საკვებს იყენებდი?",
  "ძალიან კარგი!",
  "მეც იქ ვიყავი გუშინ",
  "შენ ხარ ოსტატი 🎣"
]

# Create users
puts "Creating users..."
users = USERS_DATA.map do |user_data|
  user = User.create!(
    first_name: user_data[:first_name],
    last_name: user_data[:last_name],
    phone_number: user_data[:phone_number],
    verified: true
  )

  # Attach random avatar
  avatar_file = IMAGE_FILES.sample
  user.avatar.attach(
    io: File.open(avatar_file),
    filename: File.basename(avatar_file),
    content_type: "image/jpeg"
  )

  puts "  Created user: #{user.full_name}"
  user
end

# Create posts for each user
puts "Creating posts..."
all_posts = []

users.each do |user|
  10.times do |i|
    post = Post.new(
      user: user,
      description: DESCRIPTIONS.sample,
      specie: SPECIES.sample,
      location: LOCATIONS.sample,
      rod: RODS.sample,
      bait: BAITS.sample,
      created_at: rand(1..30).days.ago + rand(1..23).hours
    )

    # Attach random image
    image_file = IMAGE_FILES.sample
    post.image.attach(
      io: File.open(image_file),
      filename: File.basename(image_file),
      content_type: "image/jpeg"
    )

    post.save!
    all_posts << post
  end
  puts "  Created 10 posts for #{user.full_name}"
end

# Create follows (each user follows ~5 random users)
puts "Creating follows..."
users.each do |user|
  others = users.reject { |u| u == user }
  followers_to_add = others.sample(rand(4..5))

  followers_to_add.each do |other_user|
    Follow.create!(follower: other_user, followed: user)
  end
end
puts "  Created follow relationships"

# Create likes (~15 per user, distributed across posts)
puts "Creating likes..."
users.each do |user|
  posts_to_like = all_posts.reject { |p| p.user == user }.sample(15)

  posts_to_like.each do |post|
    Like.create!(user: user, post: post)
  end
end
puts "  Created likes"

# Create comments (~15 per user, distributed across posts)
puts "Creating comments..."
users.each do |user|
  posts_to_comment = all_posts.reject { |p| p.user == user }.sample(15)

  posts_to_comment.each do |post|
    Comment.create!(
      user: user,
      post: post,
      body: COMMENTS.sample,
      created_at: post.created_at + rand(1..48).hours
    )
  end
end
puts "  Created comments"

# Summary
puts "\n=== Seed Complete ==="
puts "Users: #{User.count}"
puts "Posts: #{Post.count}"
puts "Comments: #{Comment.count}"
puts "Likes: #{Like.count}"
puts "Follows: #{Follow.count}"
puts "Notifications: #{Notification.count}"

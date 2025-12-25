require 'capybara/rspec'
require 'selenium-webdriver'

# Driver for visible Chrome browser
Capybara.register_driver :selenium_chrome do |app|
  Capybara::Selenium::Driver.new(app, browser: :chrome)
end

# Driver for headless Chrome (for CI)
Capybara.register_driver :selenium_chrome_headless do |app|
  options = Selenium::WebDriver::Chrome::Options.new
  options.add_argument('--headless=new')
  options.add_argument('--disable-gpu')
  options.add_argument('--no-sandbox')
  options.add_argument('--window-size=1400,1000')

  Capybara::Selenium::Driver.new(app, browser: :chrome, options: options)
end

# Use HEADLESS=false to see the browser
if ENV['HEADLESS'] == 'false'
  Capybara.default_driver = :selenium_chrome
  Capybara.javascript_driver = :selenium_chrome
else
  Capybara.default_driver = :rack_test
  Capybara.javascript_driver = :selenium_chrome_headless
end


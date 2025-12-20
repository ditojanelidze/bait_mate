class SmsService
  def self.send_verification_code(phone_number, code)
    if Rails.env.development? || Rails.env.test?
      # Mock SMS - display in console/logs
      Rails.logger.info "=" * 50
      Rails.logger.info "SMS VERIFICATION CODE"
      Rails.logger.info "To: #{phone_number}"
      Rails.logger.info "Code: #{code}"
      Rails.logger.info "=" * 50

      # Also output to console for easier debugging
      puts "\n" + "=" * 50
      puts "SMS VERIFICATION CODE"
      puts "To: #{phone_number}"
      puts "Code: #{code}"
      puts "=" * 50 + "\n"

      true
    else
      # Production: integrate with real SMS provider (Twilio, etc.)
      # TwilioClient.send_sms(to: phone_number, body: "Your verification code: #{code}")
      raise NotImplementedError, "Production SMS not configured"
    end
  end
end

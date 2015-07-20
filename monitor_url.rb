#!/usr/bin/ruby
# This script will take in a URL to monitor and send a text message whenever
# content on that URL changes. This is useful if you're trying to keep track of
# a webpage which may not have an RSS feed or you want to ensure you get
# up-to-the-second updates on any changes to a webpage.
#
# Format:
#   monitor_url.rb URL PHONE_NUMBER_TO_TEXT GMAIL_USERNAME GMAIL_PASSWORD
#
# Example:
#   monitor_url.rb https://surkatty.org/ 2065551234@vtext.com
#  

require 'uri'
require 'net/http'
require 'digest'
require 'net/smtp'
require 'mail'

uri = URI(ARGV[0])
phone_address = ARGV[1]
gmail_username = ARGV[2]
gmail_password = ARGV[3]

monitor_file = "/tmp/.monitor_url_hash"
mail_options = { :address              => "smtp.gmail.com",
                 :port                 => 587,
                 :domain               => 'localhost',
                 :user_name            => gmail_username,
                 :password             => gmail_password,
                 :authentication       => 'plain',
                 :enable_starttls_auto => true 
                }

# Get
response = Net::HTTP.get_response(uri)
exit if response.code != "200"

# run that thang
hash = Digest::SHA256.hexdigest(response.body)
f = File.new(monitor_file, "a+")

f.write(hash) and exit if f.size == 0

f.each do |line|
  if hash != line 

    # Update the stored hash value
    File.truncate(monitor_file, 0)
    f.write(hash)

    # Set mail SMTP settings
    Mail.defaults do
      delivery_method :smtp, mail_options
    end

    # Send it
    Mail.deliver do
      to      "#{phone_address}"
      from    gmail_username
      subject "#{Time.now}"
      body    "#{uri} updated."
    end
  end
end

f.close

# This script manually loads emails that did not go in through Cloudmailin
# for whatever reason
#
# Pull in models
# (Note this should be run from the root of the repository)
require './helper'
require 'mail'


#require 'yaml'

## This script takes emails that have been saved to disk (from gmail use the "show original" option, then save to disk)
#configuration = YAML.load_file('config/manual_import_settings.yml')

## However it would be smarter to use a pop server to pull down past emails
#Mail.defaults do
#  retriever_method :pop3, :address    => "pop.gmail.com",
#                          :port       => 995,
#                          :user_name  => configuration['user_name'],
#                          :password   => configuration['password'],
#                          :enable_ssl => true
#end

# This will work in the future (didin't work with an email account with four years of emails in it)
# Mail.find(count: 1000)




# Manually grab things saved
filenames = Dir.glob('mail/*')

filenames.each do |filename|
  data = Mail.read(filename)
  message = Message.new
  begin
    message.subject = data.subject.encode('UTF-8', :invalid => :replace, :undef => :replace, :replace => '_')
    message.author = data.from.first.encode('UTF-8', :invalid => :replace, :undef => :replace, :replace => '_')
    message.received_at = data.date

    if data.parts.empty?

      body = data.body.decoded.encode('UTF-8', :invalid => :replace, :undef => :replace, :replace => '_')
      if data.content_type.include?('plain')
        message.plain = body
      elsif data.content_type.include?('html')
        message.html = body
      end

    else
      message.plain = data.parts.detect{|f| f.content_type.include?('plain') }.body.decoded.encode('UTF-8', :invalid => :replace, :undef => :replace, :replace => '_')
      message.html  = data.parts.detect{|f| f.content_type.include?('html') }.body.decoded.encode('UTF-8', :invalid => :replace, :undef => :replace, :replace => '_')
    end

    message.save
  rescue Exception => e
    binding.pry
  end

end

binding.pry
a = 5


require 'open-uri'
require 'mechanize'
require 'pry'

a = Mechanize.new

# Set user agent so they don't think we're scraping ;)
a.user_agent_alias = 'Mac Safari'

# Using facebook's mobile-optimized site because it does not depend on Javascript!
login_page = a.get('http://m.facebook.com/')


# Note that only string values are recognized in params
form = login_page.forms.first
email_field = form.field_with(name: 'email')
email_field.value = ARGV[0]
password_field = form.field_with(name: 'pass')
password_field.value = ARGV[1]

form.submit
dance_page = a.get('http://m.facebook.com/groups/sacredcircledance')
links = dance_page.links_with(:href => %r{/events/\d+})
event_ids = links.map do |link|
  link.uri.to_s.match(/\/events\/(\d+)/)
  $1
end

events = event_ids.uniq.map do |event_id|
  url = "https://graph.facebook.com/v2.5/#{event_id}?access_token=221487008193174%7C239e8bd7cbb603957391246491cff75a"
  result = begin
            open(url).read
           rescue OpenURI::HTTPError
             nil
           end
  if result.nil?
    nil
  else
    JSON.parse(result)
  end
end



binding.pry
b = 5
